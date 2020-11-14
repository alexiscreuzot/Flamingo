require 'fastlane_core/print_table'
require 'fastlane_core/command_executor'
require 'fastlane/helper/adb_helper'
require_relative 'reports_generator'
require_relative 'module'

module Screengrab
  class Runner
    NEEDED_PERMISSIONS = [
      'android.permission.READ_EXTERNAL_STORAGE',
      'android.permission.WRITE_EXTERNAL_STORAGE',
      'android.permission.CHANGE_CONFIGURATION'
    ].freeze

    attr_accessor :number_of_retries

    def initialize(executor = FastlaneCore::CommandExecutor,
                   config = Screengrab.config,
                   android_env = Screengrab.android_environment)

      @executor = executor
      @config = config
      @android_env = android_env
    end

    def run
      FastlaneCore::PrintTable.print_values(config: @config, hide_keys: [], title: "Summary for screengrab #{Fastlane::VERSION}")

      app_apk_path = @config.fetch(:app_apk_path, ask: false)
      tests_apk_path = @config.fetch(:tests_apk_path, ask: false)
      discovered_apk_paths = Dir[File.join('**', '*.apk')]

      apk_paths_provided = app_apk_path && !app_apk_path.empty? && tests_apk_path && !tests_apk_path.empty?

      unless apk_paths_provided || discovered_apk_paths.any?
        UI.error('No APK paths were provided and no APKs could be found')
        UI.error("Please provide APK paths with 'app_apk_path' and 'tests_apk_path' and make sure you have assembled APKs prior to running this command.")
        return
      end

      test_classes_to_use = @config[:use_tests_in_classes]
      test_packages_to_use = @config[:use_tests_in_packages]

      if test_classes_to_use && test_classes_to_use.any? && test_packages_to_use && test_packages_to_use.any?
        UI.error("'use_tests_in_classes' and 'use_tests_in_packages' can not be combined. Please use one or the other.")
        return
      end

      if (test_classes_to_use.nil? || test_classes_to_use.empty?) && (test_packages_to_use.nil? || test_packages_to_use.empty?)
        UI.important('Limiting the test classes run by `screengrab` to just those that generate screenshots can make runs faster.')
        UI.important('Consider using the :use_tests_in_classes or :use_tests_in_packages option, and organize your tests accordingly.')
      end

      device_type_dir_name = "#{@config[:device_type]}Screenshots"
      clear_local_previous_screenshots(device_type_dir_name)

      device_serial = select_device

      device_screenshots_paths = [
        determine_external_screenshots_path(device_serial),
        determine_internal_screenshots_paths(@config[:app_package_name], @config[:locales])
      ].flatten

      # Root is needed to access device paths at /data
      if @config[:use_adb_root]
        run_adb_command("-s #{device_serial} root", print_all: false, print_command: true)
      end

      clear_device_previous_screenshots(device_serial, device_screenshots_paths)

      app_apk_path ||= select_app_apk(discovered_apk_paths)
      tests_apk_path ||= select_tests_apk(discovered_apk_paths)

      validate_apk(app_apk_path)

      number_of_screenshots = run_tests(device_type_dir_name, device_screenshots_paths, device_serial, app_apk_path, tests_apk_path, test_classes_to_use, test_packages_to_use, @config[:launch_arguments])

      ReportsGenerator.new.generate

      UI.success("Captured #{number_of_screenshots} new screenshots! 📷✨")
    end

    def select_device
      adb = Fastlane::Helper::AdbHelper.new(adb_host: @config[:adb_host])
      devices = adb.load_all_devices

      UI.user_error!('There are no connected and authorized devices or emulators') if devices.empty?

      specific_device = @config[:specific_device]
      if specific_device
        devices.select! do |d|
          d.serial.include?(specific_device)
        end
      end

      UI.user_error!("No connected devices matched your criteria: #{specific_device}") if devices.empty?

      if devices.length > 1
        UI.important("Multiple connected devices, selecting the first one")
        UI.important("To specify which connected device to use, use the -s (specific_device) config option")
      end

      devices.first.serial
    end

    def select_app_apk(discovered_apk_paths)
      UI.important("To not be asked about this value, you can specify it using 'app_apk_path'")
      UI.select('Select your debug app APK', discovered_apk_paths)
    end

    def select_tests_apk(discovered_apk_paths)
      UI.important("To not be asked about this value, you can specify it using 'tests_apk_path'")
      UI.select('Select your debug tests APK', discovered_apk_paths)
    end

    def clear_local_previous_screenshots(device_type_dir_name)
      if @config[:clear_previous_screenshots]
        UI.message("Clearing #{device_type_dir_name} within #{@config[:output_directory]}")

        # We'll clear the temporary directory where screenshots wind up after being pulled from
        # the device as well, in case those got stranded on a previous run/failure
        ['screenshots', device_type_dir_name].each do |dir_name|
          files = screenshot_file_names_in(@config[:output_directory], dir_name)
          File.delete(*files)
        end
      end
    end

    def screenshot_file_names_in(output_directory, device_type)
      Dir.glob(File.join(output_directory, '**', device_type, '*.png'), File::FNM_CASEFOLD)
    end

    def determine_external_screenshots_path(device_serial)
      # macOS evaluates $foo in `echo $foo` before executing the command,
      # Windows doesn't - hence the double backslash vs. single backslash
      command = Helper.windows? ? "shell echo \$EXTERNAL_STORAGE " : "shell echo \\$EXTERNAL_STORAGE"
      device_ext_storage = run_adb_command("-s #{device_serial} #{command}",
                                           print_all: true,
                                           print_command: true)
      device_ext_storage = device_ext_storage.strip
      File.join(device_ext_storage, @config[:app_package_name], 'screengrab')
    end

    def determine_internal_screenshots_paths(app_package_name, locales)
      locale_paths = locales.map do |locale|
        [
          "/data/user/0/#{app_package_name}/files/#{app_package_name}/screengrab/#{locale}/images/screenshots",

          # https://github.com/fastlane/fastlane/issues/15653#issuecomment-578541663
          "/data/data/#{app_package_name}/files/#{app_package_name}/screengrab/#{locale}/images/screenshots"
        ]
      end.flatten

      return ["/data/data/#{app_package_name}/app_screengrab"] +
             ["/data/data/#{app_package_name}/screengrab"] +
             locale_paths
    end

    def clear_device_previous_screenshots(device_serial, device_screenshots_paths)
      UI.message('Cleaning screenshots on device')

      device_screenshots_paths.each do |device_path|
        if_device_path_exists(device_serial, device_path) do |path|
          run_adb_command("-s #{device_serial} shell rm -rf #{path}",
                          print_all: true,
                          print_command: true)
        end
      end
    end

    def validate_apk(app_apk_path)
      unless @android_env.aapt_path
        UI.important("The `aapt` command could not be found on your system, so your app APK could not be validated")
        return
      end

      UI.message('Validating app APK')
      apk_permissions = @executor.execute(command: "#{@android_env.aapt_path} dump permissions #{app_apk_path}",
                                          print_all: true,
                                          print_command: true)

      missing_permissions = NEEDED_PERMISSIONS.reject { |needed| apk_permissions.include?(needed) }

      if missing_permissions.any?
        UI.user_error!("The needed permission(s) #{missing_permissions.join(', ')} could not be found in your app APK")
      end
    end

    def install_apks(device_serial, app_apk_path, tests_apk_path)
      UI.message('Installing app APK')
      apk_install_output = run_adb_command("-s #{device_serial} install -t -r #{app_apk_path.shellescape}",
                                           print_all: true,
                                           print_command: true)
      UI.user_error!("App APK could not be installed") if apk_install_output.include?("Failure [")

      UI.message('Installing tests APK')
      apk_install_output = run_adb_command("-s #{device_serial} install -t -r #{tests_apk_path.shellescape}",
                                           print_all: true,
                                           print_command: true)
      UI.user_error!("Tests APK could not be installed") if apk_install_output.include?("Failure [")
    end

    def uninstall_apks(device_serial, app_package_name, tests_package_name)
      packages = installed_packages(device_serial)

      if packages.include?(app_package_name.to_s)
        UI.message('Uninstalling app APK')
        run_adb_command("-s #{device_serial} uninstall #{app_package_name}",
                        print_all: true,
                        print_command: true)
      end

      if packages.include?(tests_package_name.to_s)
        UI.message('Uninstalling tests APK')
        run_adb_command("-s #{device_serial} uninstall #{tests_package_name}",
                        print_all: true,
                        print_command: true)
      end
    end

    def grant_permissions(device_serial)
      UI.message('Granting the permission necessary to change locales on the device')
      run_adb_command("-s #{device_serial} shell pm grant #{@config[:app_package_name]} android.permission.CHANGE_CONFIGURATION",
                      print_all: true,
                      print_command: true)

      if device_api_version(device_serial) >= 23
        UI.message('Granting the permissions necessary to access device external storage')
        run_adb_command("-s #{device_serial} shell pm grant #{@config[:app_package_name]} android.permission.WRITE_EXTERNAL_STORAGE",
                        print_all: true,
                        print_command: true)
        run_adb_command("-s #{device_serial} shell pm grant #{@config[:app_package_name]} android.permission.READ_EXTERNAL_STORAGE",
                        print_all: true,
                        print_command: true)
      end
    end

    def run_tests(device_type_dir_name, device_screenshots_paths, device_serial, app_apk_path, tests_apk_path, test_classes_to_use, test_packages_to_use, launch_arguments)
      unless @config[:reinstall_app]
        install_apks(device_serial, app_apk_path, tests_apk_path)
        grant_permissions(device_serial)
        enable_clean_status_bar(device_serial, app_apk_path)
      end

      number_of_screenshots = 0

      @config[:locales].each do |locale|
        if @config[:reinstall_app]
          uninstall_apks(device_serial, @config[:app_package_name], @config[:tests_package_name])
          install_apks(device_serial, app_apk_path, tests_apk_path)
          grant_permissions(device_serial)
          enable_clean_status_bar(device_serial, app_apk_path)
        end
        number_of_screenshots += run_tests_for_locale(device_type_dir_name, device_screenshots_paths, locale, device_serial, test_classes_to_use, test_packages_to_use, launch_arguments)
      end

      number_of_screenshots
    end

    def run_tests_for_locale(device_type_dir_name, device_screenshots_paths, locale, device_serial, test_classes_to_use, test_packages_to_use, launch_arguments)
      UI.message("Running tests for locale: #{locale}")

      instrument_command = ["-s #{device_serial} shell am instrument --no-window-animation -w",
                            "-e testLocale #{locale.tr('-', '_')}",
                            "-e endingLocale #{@config[:ending_locale].tr('-', '_')}"]
      instrument_command << "-e appendTimestamp #{@config[:use_timestamp_suffix]}"
      instrument_command << "-e class #{test_classes_to_use.join(',')}" if test_classes_to_use
      instrument_command << "-e package #{test_packages_to_use.join(',')}" if test_packages_to_use
      instrument_command << launch_arguments.map { |item| '-e ' + item }.join(' ') if launch_arguments
      instrument_command << "#{@config[:tests_package_name]}/#{@config[:test_instrumentation_runner]}"

      test_output = run_adb_command(instrument_command.join(" \\\n"),
                                    print_all: true,
                                    print_command: true)

      if test_output.include?("FAILURES!!!")
        if @config[:exit_on_test_failure]
          UI.test_failure!("Tests failed for locale #{locale} on device #{device_serial}")
        else
          UI.error("Tests failed")
        end
      end

      pull_screenshots_from_device(locale, device_serial, device_screenshots_paths, device_type_dir_name)
    end

    def pull_screenshots_from_device(locale, device_serial, device_screenshots_paths, device_type_dir_name)
      UI.message("Pulling captured screenshots for locale #{locale} from the device")
      starting_screenshot_count = screenshot_file_names_in(@config[:output_directory], device_type_dir_name).length

      UI.verbose("Starting screenshot count is: #{starting_screenshot_count}")

      # Make a temp directory into which to pull the screenshots before they are moved to their final location.
      # This makes directory cleanup easier, as the temp directory will be removed when the block completes.

      Dir.mktmpdir do |tempdir|
        device_screenshots_paths.each do |device_path|
          if_device_path_exists(device_serial, device_path) do |path|
            next unless path.include?(locale)
            run_adb_command("-s #{device_serial} pull #{path} #{tempdir}",
                            print_all: false,
                            print_command: true)
          end
        end

        # The SDK can't 100% determine what kind of device it is running on relative to the categories that
        # supply and Google Play care about (phone, 7" tablet, TV, etc.).
        #
        # Therefore, we'll move the pulled screenshots from their genericly named folder to one named by the
        # user provided device_type option value to match the directory structure that supply expects
        move_pulled_screenshots(locale, tempdir, device_type_dir_name)
      end

      ending_screenshot_count = screenshot_file_names_in(@config[:output_directory], device_type_dir_name).length

      UI.verbose("Ending screenshot count is: #{ending_screenshot_count}")

      # Because we can't guarantee the screenshot output directory will be empty when we pull, we determine
      # success based on whether there are more screenshots there than when we started.
      # This is only applicable though when `clear_previous_screenshots` is set to `true`.
      if starting_screenshot_count == ending_screenshot_count && @config[:clear_previous_screenshots]
        UI.error("Make sure you've used Screengrab.screenshot() in your tests and that your expected tests are being run.")
        UI.abort_with_message!("No screenshots were detected 📷❌")
      end

      ending_screenshot_count - starting_screenshot_count
    end

    def move_pulled_screenshots(locale, pull_dir, device_type_dir_name)
      # Glob pattern that finds the pulled screenshots directory for each locale
      # Possible matches:
      #   [pull_dir]/en-US/images/screenshots
      #   [pull_dir]/screengrab/en-US/images/screenshots
      screenshots_dir_pattern = File.join(pull_dir, '**', "screenshots")

      Dir.glob(screenshots_dir_pattern, File::FNM_CASEFOLD).each do |screenshots_dir|
        src_screenshots = Dir.glob(File.join(screenshots_dir, '*.png'), File::FNM_CASEFOLD)

        # The :output_directory is the final location for the screenshots, so we begin by replacing
        # the temp directory portion of the path, with the output directory
        dest_dir = screenshots_dir.gsub(pull_dir, @config[:output_directory])

        # Different versions of adb are inconsistent about whether they will pull down the containing
        # directory for the screenshots, so we'll try to remove that path from the directory name when
        # creating the destination path.
        # See: https://github.com/fastlane/fastlane/pull/4915#issuecomment-236368649
        dest_dir = dest_dir.gsub(%r{(app_)?screengrab/}, '')

        # We then replace the last segment of the screenshots directory path with the device_type
        # specific name, as expected by supply
        #
        # (Moved to: fastlane/metadata/android/en-US/images/phoneScreenshots)
        dest_dir = File.join(File.dirname(dest_dir), locale, 'images', device_type_dir_name)

        FileUtils.mkdir_p(dest_dir)
        FileUtils.cp_r(src_screenshots, dest_dir)
        UI.success("Screenshots copied to #{dest_dir}")
      end
    end

    # Some device commands fail if executed against a device path that does not exist, so this helper method
    # provides a way to conditionally execute a block only if the provided path exists on the device.
    def if_device_path_exists(device_serial, device_path)
      return if run_adb_command("-s #{device_serial} shell ls #{device_path}",
                                print_all: false,
                                print_command: false).include?('No such file')

      yield(device_path)
    rescue
      # Some versions of ADB will have a non-zero exit status for this, which will cause the executor to raise.
      # We can safely ignore that and treat it as if it returned 'No such file'
    end

    # Return an array of packages that are installed on the device
    def installed_packages(device_serial)
      packages = run_adb_command("-s #{device_serial} shell pm list packages",
                                 print_all: true,
                                 print_command: true)
      packages.split("\n").map { |package| package.gsub("package:", "") }
    end

    def run_adb_command(command, print_all: false, print_command: false)
      adb_path = @android_env.adb_path.chomp("adb")
      adb_host = @config[:adb_host]
      host = adb_host.nil? ? '' : "-H #{adb_host} "
      output = @executor.execute(command: adb_path + "adb " + host + command,
                                 print_all: print_all,
                                 print_command: print_command) || ''
      output.lines.reject do |line|
        # Debug/Warning output from ADB}
        line.start_with?('adb: ')
      end.join('') # Lines retain their newline chars
    end

    def device_api_version(device_serial)
      run_adb_command("-s #{device_serial} shell getprop ro.build.version.sdk",
                      print_all: true, print_command: true).to_i
    end

    def enable_clean_status_bar(device_serial, app_apk_path)
      return unless device_api_version(device_serial) >= 23

      unless @android_env.aapt_path
        UI.error("The `aapt` command could not be found, so status bar could not be cleaned. Make sure android_home is configured for screengrab or ANDROID_HOME is set in the environment")
        return
      end

      # Check if the app wants to use the clean status bar feature
      badging_dump = @executor.execute(command: "#{@android_env.aapt_path} dump badging #{app_apk_path}",
                                       print_all: true, print_command: true)
      return unless badging_dump.include?('uses-feature: name=\'tools.fastlane.screengrab.cleanstatusbar\'')

      UI.message('Enabling clean status bar')

      # Make sure the app requests the DUMP permission
      unless badging_dump.include?('uses-permission: name=\'android.permission.DUMP\'')
        UI.user_error!("The clean status bar feature requires the android.permission.DUMP permission but it could not be found in your app APK")
      end

      # Grant the DUMP permission
      run_adb_command("-s #{device_serial} shell pm grant #{@config[:app_package_name]} android.permission.DUMP",
                      print_all: true, print_command: true)

      # Enable the SystemUI demo mode
      run_adb_command("-s #{device_serial} shell settings put global sysui_demo_allowed 1",
                      print_all: true, print_command: true)
    end
  end
end
