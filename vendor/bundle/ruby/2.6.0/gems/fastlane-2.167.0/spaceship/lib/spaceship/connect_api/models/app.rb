require_relative '../model'
require_relative './build'

module Spaceship
  class ConnectAPI
    class App
      include Spaceship::ConnectAPI::Model

      attr_accessor :name
      attr_accessor :bundle_id
      attr_accessor :sku
      attr_accessor :primary_locale
      attr_accessor :is_opted_in_to_distribute_ios_app_on_mac_app_store
      attr_accessor :removed
      attr_accessor :is_aag
      attr_accessor :available_in_new_territories
      attr_accessor :content_rights_declaration
      attr_accessor :app_store_versions
      attr_accessor :prices

      # Only available with Apple ID auth
      attr_accessor :distribution_type
      attr_accessor :educationDiscountType

      module ContentRightsDeclaration
        USES_THIRD_PARTY_CONTENT = "USES_THIRD_PARTY_CONTENT"
        DOES_NOT_USE_THIRD_PARTY_CONTENT = "DOES_NOT_USE_THIRD_PARTY_CONTENT"
      end

      module DistributionType
        APP_STORE = "APP_STORE"
        CUSTOM = "CUSTOM"
      end

      module EducationDiscountType
        DISCOUNTED = "DISCOUNTED"
        NOT_APPLICABLE = "NOT_APPLICABLE"
        NOT_DISCOUNTED = "NOT_DISCOUNTED"
      end

      self.attr_mapping({
        "name" => "name",
        "bundleId" => "bundle_id",
        "sku" => "sku",
        "primaryLocale" => "primary_locale",
        "isOptedInToDistributeIosAppOnMacAppStore" => "is_opted_in_to_distribute_ios_app_on_mac_app_store",
        "removed" => "removed",
        "isAAG" => "is_aag",
        "availableInNewTerritories" => "available_in_new_territories",
        "distributionType" => "distribution_type",
        "educationDiscountType" => "education_discount_type",

        "contentRightsDeclaration" => "content_rights_declaration",

        "appStoreVersions" => "app_store_versions",
        "prices" => "prices"
      })

      ESSENTIAL_INCLUDES = [
        "appStoreVersions",
        "prices"
      ].join(",")

      def self.type
        return "apps"
      end

      #
      # Apps
      #

      def self.all(filter: {}, includes: ESSENTIAL_INCLUDES, limit: nil, sort: nil)
        resps = Spaceship::ConnectAPI.get_apps(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.find(bundle_id)
        return all(filter: { bundleId: bundle_id }).find do |app|
          app.bundle_id == bundle_id
        end
      end

      def self.create(name: nil, version_string: nil, sku: nil, primary_locale: nil, bundle_id: nil, platforms: nil, company_name: nil)
        Spaceship::ConnectAPI.post_app(
          name: name,
          version_string: version_string,
          sku: sku,
          primary_locale: primary_locale,
          bundle_id: bundle_id,
          platforms: platforms,
          company_name: company_name
        )
      end

      def self.get(app_id: nil, includes: "appStoreVersions")
        return Spaceship::ConnectAPI.get_app(app_id: app_id, includes: includes).first
      end

      def update(attributes: nil, app_price_tier_id: nil, territory_ids: nil)
        attributes = reverse_attr_mapping(attributes)
        return Spaceship::ConnectAPI.patch_app(app_id: id, attributes: attributes, app_price_tier_id: app_price_tier_id, territory_ids: territory_ids)
      end

      #
      # App Info
      #

      def fetch_live_app_info(includes: Spaceship::ConnectAPI::AppInfo::ESSENTIAL_INCLUDES)
        states = [
          Spaceship::ConnectAPI::AppInfo::AppStoreState::READY_FOR_SALE,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::PENDING_APPLE_RELEASE,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::PENDING_DEVELOPER_RELEASE,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::PROCESSING_FOR_APP_STORE,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::IN_REVIEW
        ]

        resp = Spaceship::ConnectAPI.get_app_infos(app_id: id, includes: includes)
        return resp.to_models.select do |model|
          states.include?(model.app_store_state)
        end.first
      end

      def fetch_edit_app_info(includes: Spaceship::ConnectAPI::AppInfo::ESSENTIAL_INCLUDES)
        states = [
          Spaceship::ConnectAPI::AppInfo::AppStoreState::PREPARE_FOR_SUBMISSION,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::DEVELOPER_REJECTED,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::REJECTED,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::METADATA_REJECTED,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::WAITING_FOR_REVIEW,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::INVALID_BINARY
        ]

        resp = Spaceship::ConnectAPI.get_app_infos(app_id: id, includes: includes)
        return resp.to_models.select do |model|
          states.include?(model.app_store_state)
        end.first
      end

      #
      # Available Territories
      #

      def fetch_available_territories(filter: {}, includes: nil, limit: nil, sort: nil)
        filter ||= {}
        resps = Spaceship::ConnectAPI.get_available_territories(app_id: id, filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      #
      # App Pricing
      #

      def fetch_app_prices(filter: {}, includes: "priceTier", limit: nil, sort: nil)
        resp = Spaceship::ConnectAPI.get_app_prices(app_id: id, filter: filter, includes: includes, limit: limit, sort: sort)
        return resp.to_models
      end

      #
      # App Store Versions
      #

      def reject_version_if_possible!(platform: nil)
        platform ||= Spaceship::ConnectAPI::Platform::IOS
        filter = {
          appStoreState: [
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::PENDING_APPLE_RELEASE,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::PENDING_DEVELOPER_RELEASE,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::IN_REVIEW,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::WAITING_FOR_REVIEW
          ].join(","),
          platform: platform
        }

        # Get the latest version
        version = get_app_store_versions(filter: filter, includes: "appStoreVersionSubmission")
                  .sort_by { |v| Gem::Version.new(v.version_string) }
                  .last

        return false if version.nil?
        return version.reject!
      end

      # Will make sure the current edit_version matches the given version number
      # This will either create a new version or change the version number
      # from an existing version
      # @return (Bool) Was something changed?
      def ensure_version!(version_string, platform: nil)
        app_store_version = get_edit_app_store_version(platform: platform)

        if app_store_version
          if version_string != app_store_version.version_string
            attributes = { versionString: version_string }
            app_store_version.update(attributes: attributes)
            return true
          end
          return false
        else
          attributes = { versionString: version_string, platform: platform }
          Spaceship::ConnectAPI.post_app_store_version(app_id: id, attributes: attributes)

          return true
        end
      end

      def get_latest_app_store_version(platform: nil, includes: nil)
        platform ||= Spaceship::ConnectAPI::Platform::IOS
        filter = {
          platform: platform
        }

        # Get the latest version
        return get_app_store_versions(filter: filter, includes: includes)
               .sort_by { |v| Date.parse(v.created_date) }
               .last
      end

      def get_live_app_store_version(platform: nil, includes: Spaceship::ConnectAPI::AppStoreVersion::ESSENTIAL_INCLUDES)
        platform ||= Spaceship::ConnectAPI::Platform::IOS
        filter = {
          appStoreState: Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::READY_FOR_SALE,
          platform: platform
        }
        return get_app_store_versions(filter: filter, includes: includes).first
      end

      def get_edit_app_store_version(platform: nil, includes: Spaceship::ConnectAPI::AppStoreVersion::ESSENTIAL_INCLUDES)
        platform ||= Spaceship::ConnectAPI::Platform::IOS
        filter = {
          appStoreState: [
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::PREPARE_FOR_SUBMISSION,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::DEVELOPER_REJECTED,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::REJECTED,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::METADATA_REJECTED,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::WAITING_FOR_REVIEW,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::INVALID_BINARY
          ].join(","),
          platform: platform
        }

        # Get the latest version
        return get_app_store_versions(filter: filter, includes: includes)
               .sort_by { |v| Gem::Version.new(v.version_string) }
               .last
      end

      def get_in_review_app_store_version(platform: nil, includes: Spaceship::ConnectAPI::AppStoreVersion::ESSENTIAL_INCLUDES)
        platform ||= Spaceship::ConnectAPI::Platform::IOS
        filter = {
          appStoreState: Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::IN_REVIEW,
          platform: platform
        }
        return get_app_store_versions(filter: filter, includes: includes).first
      end

      def get_pending_release_app_store_version(platform: nil, includes: Spaceship::ConnectAPI::AppStoreVersion::ESSENTIAL_INCLUDES)
        platform ||= Spaceship::ConnectAPI::Platform::IOS
        filter = {
          appStoreState: [
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::PENDING_APPLE_RELEASE,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::PENDING_DEVELOPER_RELEASE
          ].join(','),
          platform: platform
        }
        return get_app_store_versions(filter: filter, includes: includes).first
      end

      def get_app_store_versions(filter: {}, includes: Spaceship::ConnectAPI::AppStoreVersion::ESSENTIAL_INCLUDES, limit: nil, sort: nil)
        resps = Spaceship::ConnectAPI.get_app_store_versions(app_id: id, filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      #
      # B2B
      #

      def disable_b2b
        update(attributes: {
          distributionType: DistributionType::APP_STORE,
          education_discount_type: EducationDiscountType::NOT_DISCOUNTED
        })
      end

      def enable_b2b
        update(attributes: {
          distributionType: App::DistributionType::CUSTOM,
          education_discount_type: EducationDiscountType::NOT_APPLICABLE
        })
      end

      #
      # Beta Feedback
      #

      def get_beta_feedback(filter: {}, includes: "tester,build,screenshots", limit: nil, sort: nil)
        filter ||= {}
        filter["build.app"] = id

        resps = Spaceship::ConnectAPI.get_beta_feedback(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      #
      # Beta Testers
      #

      def get_beta_testers(filter: {}, includes: nil, limit: nil, sort: nil)
        filter ||= {}
        filter[:apps] = id

        resps = Spaceship::ConnectAPI.get_beta_testers(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      #
      # Builds
      #

      def get_builds(filter: {}, includes: nil, limit: nil, sort: nil)
        filter ||= {}
        filter[:app] = id

        resps = Spaceship::ConnectAPI.get_builds(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def get_build_deliveries(filter: {}, includes: nil, limit: nil, sort: nil)
        filter ||= {}
        filter[:app] = id

        resps = Spaceship::ConnectAPI.get_build_deliveries(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def get_beta_app_localizations(filter: {}, includes: nil, limit: nil, sort: nil)
        filter ||= {}
        filter[:app] = id

        resps = Spaceship::ConnectAPI.get_beta_app_localizations(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def get_beta_groups(filter: {}, includes: nil, limit: nil, sort: nil)
        filter ||= {}
        filter[:app] = id

        resps = Spaceship::ConnectAPI.get_beta_groups(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def create_beta_group(group_name: nil, public_link_enabled: false, public_link_limit: 10_000, public_link_limit_enabled: false)
        resps = Spaceship::ConnectAPI.create_beta_group(
          app_id: id,
          group_name: group_name,
          public_link_enabled: public_link_enabled,
          public_link_limit: public_link_limit,
          public_link_limit_enabled: public_link_limit_enabled
        ).all_pages
        return resps.flat_map(&:to_models).first
      end

      #
      # Education
      #

      def disable_educational_discount
        update(attributes: {
          education_discount_type: EducationDiscountType::NOT_DISCOUNTED
        })
      end

      def enable_educational_discount
        update(attributes: {
          education_discount_type: EducationDiscountType::DISCOUNTED
        })
      end

      #
      # Users
      #

      def add_users(user_ids: nil)
        user_ids.each do |user_id|
          Spaceship::ConnectAPI.add_user_visible_apps(user_id: user_id, app_ids: [id])
        end
      end
    end
  end
end
