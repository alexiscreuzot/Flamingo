//
//  MaterialIcon
//  ambassador
//
//  Created by Alexis Creuzot on 04/07/2019.
//  Copyright © 2019 alexiscreuzot. All rights reserved.
//

import Foundation
import UIKit

extension MaterialIcon {
    static func font(size: CGFloat) -> UIFont {
        return UIFont(name: "material-icons", size: size)!
    }
    
    func attributesFor(size: CGFloat, color: UIColor, baselineOffset: CGFloat = 0.0) -> [NSAttributedString.Key : Any] {
        return [.foregroundColor: color,
                .backgroundColor: UIColor.clear,
                .baselineOffset : baselineOffset,
                .font: MaterialIcon.font(size: size)]
    }
    
    func attributedString(size: CGFloat, color: UIColor, baselineOffset: CGFloat = 0.0) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self.rawValue,
                                         attributes: self.attributesFor(size: size, color: color, baselineOffset: baselineOffset))
    }
    
    func imageFor(size: CGFloat, color: UIColor) -> UIImage? {
        
        let imageSize = CGSize.init(width: size, height: size)
        let attributes = self.attributesFor(size: size, color: color)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        let rect = CGRect(origin: .zero, size: imageSize)
        self.rawValue.draw(in: rect, withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.withRenderingMode(.alwaysOriginal)
    }
}

enum MaterialIcon : String {
    
    case error = "\u{e900}"
    case error_outline = "\u{e901}"
    case warning = "\u{e902}"
    case add_alert = "\u{e903}"
    case notification_important = "\u{e904}"
    case album = "\u{e905}"
    case av_timer = "\u{e906}"
    case closed_caption = "\u{e907}"
    case equalizer = "\u{e908}"
    case explicit = "\u{e909}"
    case fast_forward = "\u{e90a}"
    case fast_rewind = "\u{e90b}"
    case games = "\u{e90c}"
    case hearing = "\u{e90d}"
    case high_quality = "\u{e90e}"
    case loop = "\u{e90f}"
    case mic = "\u{e910}"
    case mic_none = "\u{e911}"
    case mic_off = "\u{e912}"
    case movie = "\u{e913}"
    case library_add = "\u{e914}"
    case library_books = "\u{e915}"
    case library_music = "\u{e916}"
    case new_releases = "\u{e917}"
    case not_interested = "\u{e918}"
    case pause = "\u{e919}"
    case pause_circle_filled = "\u{e91a}"
    case pause_circle_outline = "\u{e91b}"
    case play_arrow = "\u{e91c}"
    case play_circle_filled = "\u{e91d}"
    case play_circle_outline = "\u{e91e}"
    case playlist_add = "\u{e91f}"
    case queue_music = "\u{e920}"
    case radio = "\u{e921}"
    case recent_actors = "\u{e922}"
    case `repeat` = "\u{e923}"
    case repeat_one = "\u{e924}"
    case replay = "\u{e925}"
    case shuffle = "\u{e926}"
    case skip_next = "\u{e927}"
    case skip_previous = "\u{e928}"
    case snooze = "\u{e929}"
    case stop = "\u{e92a}"
    case subtitles = "\u{e92b}"
    case surround_sound = "\u{e92c}"
    case video_collection = "\u{e92d}"
    case videocam = "\u{e92e}"
    case videocam_off = "\u{e92f}"
    case volume_down = "\u{e930}"
    case volume_mute = "\u{e931}"
    case volume_off = "\u{e932}"
    case volume_up = "\u{e933}"
    case web = "\u{e934}"
    case hd = "\u{e935}"
    case sort_by_alpha = "\u{e936}"
    case airplay = "\u{e937}"
    case forward_10 = "\u{e938}"
    case forward_30 = "\u{e939}"
    case forward_5 = "\u{e93a}"
    case replay_10 = "\u{e93b}"
    case replay_30 = "\u{e93c}"
    case replay_5 = "\u{e93d}"
    case add_to_queue = "\u{e93e}"
    case fiber_dvr = "\u{e93f}"
    case fiber_new = "\u{e940}"
    case playlist_play = "\u{e941}"
    case art_track = "\u{e942}"
    case fiber_manual_record = "\u{e943}"
    case fiber_smart_record = "\u{e944}"
    case music_video = "\u{e945}"
    case subscriptions = "\u{e946}"
    case playlist_add_check = "\u{e947}"
    case queue_play_next = "\u{e948}"
    case remove_from_queue = "\u{e949}"
    case slow_motion_video = "\u{e94a}"
    case web_asset = "\u{e94b}"
    case fiber_pin = "\u{e94c}"
    case branding_watermark = "\u{e94d}"
    case call_to_action = "\u{e94e}"
    case featured_play_list = "\u{e94f}"
    case featured_video = "\u{e950}"
    case note = "\u{e951}"
    case video_call = "\u{e952}"
    case video_label = "\u{e953}"
    case missed_video_call = "\u{e955}"
    case control_camera = "\u{e956}"
    case business = "\u{e957}"
    case call = "\u{e958}"
    case call_end = "\u{e959}"
    case call_made = "\u{e95a}"
    case call_merge = "\u{e95b}"
    case call_missed = "\u{e95c}"
    case call_received = "\u{e95d}"
    case call_split = "\u{e95e}"
    case chat = "\u{e95f}"
    case clear_all = "\u{e960}"
    case comment = "\u{e961}"
    case contacts = "\u{e962}"
    case dialer_sip = "\u{e963}"
    case dialpad = "\u{e964}"
    case email = "\u{e965}"
    case forum = "\u{e966}"
    case import_export = "\u{e967}"
    case invert_colors_off = "\u{e968}"
    case live_help = "\u{e969}"
    case location_off = "\u{e96a}"
    case location_on = "\u{e96b}"
    case message = "\u{e96c}"
    case chat_bubble = "\u{e96d}"
    case chat_bubble_outline = "\u{e96e}"
    case no_sim = "\u{e96f}"
    case phone = "\u{e970}"
    case portable_wifi_off = "\u{e971}"
    case contact_phone = "\u{e972}"
    case contact_mail = "\u{e973}"
    case ring_volume = "\u{e974}"
    case speaker_phone = "\u{e975}"
    case stay_current_landscape = "\u{e976}"
    case stay_current_portrait = "\u{e977}"
    case swap_calls = "\u{e978}"
    case textsms = "\u{e979}"
    case voicemail = "\u{e97a}"
    case vpn_key = "\u{e97b}"
    case phonelink_erase = "\u{e97c}"
    case phonelink_lock = "\u{e97d}"
    case phonelink_ring = "\u{e97e}"
    case phonelink_setup = "\u{e97f}"
    case present_to_all = "\u{e980}"
    case import_contacts = "\u{e981}"
    case mail_outline = "\u{e982}"
    case screen_share = "\u{e983}"
    case stop_screen_share = "\u{e984}"
    case call_missed_outgoing = "\u{e985}"
    case rss_feed = "\u{e986}"
    case alternate_email = "\u{e987}"
    case mobile_screen_share = "\u{e988}"
    case add_call = "\u{e989}"
    case cancel_presentation = "\u{e98a}"
    case pause_presentation = "\u{e98b}"
    case unsubscribe = "\u{e98c}"
    case cell_wifi = "\u{e98d}"
    case sentiment_satisfied_alt = "\u{e98e}"
    case list_alt = "\u{e98f}"
    case domain_disabled = "\u{e990}"
    case lightbulb = "\u{e991}"
    case add = "\u{e992}"
    case add_box = "\u{e993}"
    case add_circle = "\u{e994}"
    case add_circle_outline = "\u{e995}"
    case archive = "\u{e996}"
    case backspace = "\u{e997}"
    case block = "\u{e998}"
    case clear = "\u{e999}"
    case content_copy = "\u{e99a}"
    case content_cut = "\u{e99b}"
    case content_paste = "\u{e99c}"
    case create = "\u{e99d}"
    case drafts = "\u{e99e}"
    case filter_list = "\u{e99f}"
    case flag = "\u{e9a0}"
    case forward = "\u{e9a1}"
    case gesture = "\u{e9a2}"
    case inbox = "\u{e9a3}"
    case link = "\u{e9a4}"
    case redo = "\u{e9a5}"
    case remove = "\u{e9a6}"
    case remove_circle = "\u{e9a7}"
    case remove_circle_outline = "\u{e9a8}"
    case reply = "\u{e9a9}"
    case reply_all = "\u{e9aa}"
    case report = "\u{e9ab}"
    case save = "\u{e9ac}"
    case select_all = "\u{e9ad}"
    case send = "\u{e9ae}"
    case sort = "\u{e9af}"
    case text_format = "\u{e9b0}"
    case undo = "\u{e9b1}"
    case font_download = "\u{e9b2}"
    case move_to_inbox = "\u{e9b3}"
    case unarchive = "\u{e9b4}"
    case next_week = "\u{e9b5}"
    case weekend = "\u{e9b6}"
    case delete_sweep = "\u{e9b7}"
    case low_priority = "\u{e9b8}"
    case outlined_flag = "\u{e9b9}"
    case link_off = "\u{e9ba}"
    case report_off = "\u{e9bb}"
    case save_alt = "\u{e9bc}"
    case ballot = "\u{e9bd}"
    case file_copy = "\u{e9be}"
    case how_to_reg = "\u{e9bf}"
    case how_to_vote = "\u{e9c0}"
    case waves = "\u{e9c1}"
    case where_to_vote = "\u{e9c2}"
    case add_link = "\u{e9c3}"
    case inventory = "\u{e9c4}"
    case access_alarm = "\u{e9c5}"
    case access_alarms = "\u{e9c6}"
    case access_time = "\u{e9c7}"
    case add_alarm = "\u{e9c8}"
    case airplanemode_inactive = "\u{e9c9}"
    case airplanemode_active = "\u{e9ca}"
    case battery_alert = "\u{e9cb}"
    case battery_charging_full = "\u{e9cc}"
    case battery_full = "\u{e9cd}"
    case battery_unknown = "\u{e9ce}"
    case bluetooth = "\u{e9cf}"
    case bluetooth_connected = "\u{e9d0}"
    case bluetooth_disabled = "\u{e9d1}"
    case bluetooth_searching = "\u{e9d2}"
    case brightness_auto = "\u{e9d3}"
    case brightness_high = "\u{e9d4}"
    case brightness_low = "\u{e9d5}"
    case brightness_medium = "\u{e9d6}"
    case data_usage = "\u{e9d7}"
    case developer_mode = "\u{e9d8}"
    case devices = "\u{e9d9}"
    case dvr = "\u{e9da}"
    case gps_fixed = "\u{e9db}"
    case gps_not_fixed = "\u{e9dc}"
    case gps_off = "\u{e9dd}"
    case graphic_eq = "\u{e9de}"
    case network_cell = "\u{e9df}"
    case network_wifi = "\u{e9e0}"
    case nfc = "\u{e9e1}"
    case now_wallpaper = "\u{e9e2}"
    case now_widgets = "\u{e9e3}"
    case screen_lock_landscape = "\u{e9e4}"
    case screen_lock_portrait = "\u{e9e5}"
    case screen_lock_rotation = "\u{e9e6}"
    case screen_rotation = "\u{e9e7}"
    case sd_storage = "\u{e9e8}"
    case settings_system_daydream = "\u{e9e9}"
    case signal_cellular_4_bar = "\u{e9ea}"
    case signal_cellular_connected_no_internet_4_bar = "\u{e9eb}"
    case signal_cellular_null = "\u{e9ec}"
    case signal_cellular_off = "\u{e9ed}"
    case signal_wifi_4_bar = "\u{e9ee}"
    case signal_wifi_4_bar_lock = "\u{e9ef}"
    case signal_wifi_off = "\u{e9f0}"
    case storage = "\u{e9f1}"
    case usb = "\u{e9f2}"
    case wifi_lock = "\u{e9f3}"
    case wifi_tethering = "\u{e9f4}"
    case add_to_home_screen = "\u{e9f5}"
    case device_thermostat = "\u{e9f6}"
    case mobile_friendly = "\u{e9f7}"
    case mobile_off = "\u{e9f8}"
    case signal_cellular_alt = "\u{e9f9}"
    case attach_file = "\u{e9fa}"
    case attach_money = "\u{e9fb}"
    case border_all = "\u{e9fc}"
    case border_bottom = "\u{e9fd}"
    case border_clear = "\u{e9fe}"
    case border_color = "\u{e9ff}"
    case border_horizontal = "\u{ea00}"
    case border_inner = "\u{ea01}"
    case border_left = "\u{ea02}"
    case border_outer = "\u{ea03}"
    case border_right = "\u{ea04}"
    case border_style = "\u{ea05}"
    case border_top = "\u{ea06}"
    case border_vertical = "\u{ea07}"
    case format_align_center = "\u{ea08}"
    case format_align_justify = "\u{ea09}"
    case format_align_left = "\u{ea0a}"
    case format_align_right = "\u{ea0b}"
    case format_bold = "\u{ea0c}"
    case format_clear = "\u{ea0d}"
    case format_color_fill = "\u{ea0e}"
    case format_color_reset = "\u{ea0f}"
    case format_color_text = "\u{ea10}"
    case format_indent_decrease = "\u{ea11}"
    case format_indent_increase = "\u{ea12}"
    case format_italic = "\u{ea13}"
    case format_line_spacing = "\u{ea14}"
    case format_list_bulleted = "\u{ea15}"
    case format_list_numbered = "\u{ea16}"
    case format_paint = "\u{ea17}"
    case format_quote = "\u{ea18}"
    case format_size = "\u{ea19}"
    case format_strikethrough = "\u{ea1a}"
    case format_textdirection_l_to_r = "\u{ea1b}"
    case format_textdirection_r_to_l = "\u{ea1c}"
    case format_underlined = "\u{ea1d}"
    case functions = "\u{ea1e}"
    case insert_chart = "\u{ea1f}"
    case insert_comment = "\u{ea20}"
    case insert_drive_file = "\u{ea21}"
    case insert_emoticon = "\u{ea22}"
    case insert_invitation = "\u{ea23}"
    case insert_photo = "\u{ea24}"
    case mode_comment = "\u{ea25}"
    case publish = "\u{ea26}"
    case space_bar = "\u{ea27}"
    case strikethrough_s = "\u{ea28}"
    case vertical_align_bottom = "\u{ea29}"
    case vertical_align_center = "\u{ea2a}"
    case vertical_align_top = "\u{ea2b}"
    case wrap_text = "\u{ea2c}"
    case money_off = "\u{ea2d}"
    case drag_handle = "\u{ea2e}"
    case format_shapes = "\u{ea2f}"
    case highlight = "\u{ea30}"
    case linear_scale = "\u{ea31}"
    case short_text = "\u{ea32}"
    case text_fields = "\u{ea33}"
    case monetization_on = "\u{ea34}"
    case title = "\u{ea35}"
    case table_chart = "\u{ea36}"
    case add_comment = "\u{ea37}"
    case format_list_numbered_rtl = "\u{ea38}"
    case scatter_plot = "\u{ea39}"
    case score = "\u{ea3a}"
    case insert_chart_outlined = "\u{ea3b}"
    case bar_chart = "\u{ea3c}"
    case notes = "\u{ea3d}"
    case attachment = "\u{ea3e}"
    case cloud = "\u{ea3f}"
    case cloud_circle = "\u{ea40}"
    case cloud_done = "\u{ea41}"
    case cloud_download = "\u{ea42}"
    case cloud_off = "\u{ea43}"
    case cloud_queue = "\u{ea44}"
    case cloud_upload = "\u{ea45}"
    case file_download = "\u{ea46}"
    case file_upload = "\u{ea47}"
    case folder = "\u{ea48}"
    case folder_open = "\u{ea49}"
    case folder_shared = "\u{ea4a}"
    case create_new_folder = "\u{ea4b}"
    case cast = "\u{ea4c}"
    case cast_connected = "\u{ea4d}"
    case computer = "\u{ea4e}"
    case desktop_mac = "\u{ea4f}"
    case desktop_windows = "\u{ea50}"
    case developer_board = "\u{ea51}"
    case dock = "\u{ea52}"
    case headset = "\u{ea53}"
    case headset_mic = "\u{ea54}"
    case keyboard = "\u{ea55}"
    case keyboard_arrow_down = "\u{ea56}"
    case keyboard_arrow_left = "\u{ea57}"
    case keyboard_arrow_right = "\u{ea58}"
    case keyboard_arrow_up = "\u{ea59}"
    case keyboard_backspace = "\u{ea5a}"
    case keyboard_capslock = "\u{ea5b}"
    case keyboard_hide = "\u{ea5c}"
    case keyboard_return = "\u{ea5d}"
    case keyboard_tab = "\u{ea5e}"
    case keyboard_voice = "\u{ea5f}"
    case laptop_chromebook = "\u{ea60}"
    case laptop_mac = "\u{ea61}"
    case laptop_windows = "\u{ea62}"
    case memory = "\u{ea63}"
    case mouse = "\u{ea64}"
    case phone_android = "\u{ea65}"
    case phone_iphone = "\u{ea66}"
    case phonelink_off = "\u{ea67}"
    case router = "\u{ea68}"
    case scanner = "\u{ea69}"
    case security = "\u{ea6a}"
    case sim_card = "\u{ea6b}"
    case speaker = "\u{ea6c}"
    case speaker_group = "\u{ea6d}"
    case tablet = "\u{ea6e}"
    case tablet_android = "\u{ea6f}"
    case tablet_mac = "\u{ea70}"
    case toys = "\u{ea71}"
    case tv = "\u{ea72}"
    case watch = "\u{ea73}"
    case device_hub = "\u{ea74}"
    case power_input = "\u{ea75}"
    case devices_other = "\u{ea76}"
    case videogame_asset = "\u{ea77}"
    case device_unknown = "\u{ea78}"
    case headset_off = "\u{ea79}"
    case adjust = "\u{ea7a}"
    case assistant = "\u{ea7b}"
    case audiotrack = "\u{ea7c}"
    case blur_circular = "\u{ea7d}"
    case blur_linear = "\u{ea7e}"
    case blur_off = "\u{ea7f}"
    case blur_on = "\u{ea80}"
    case brightness_1 = "\u{ea81}"
    case brightness_2 = "\u{ea82}"
    case brightness_3 = "\u{ea83}"
    case brightness_4 = "\u{ea84}"
    case broken_image = "\u{ea85}"
    case brush = "\u{ea86}"
    case camera = "\u{ea87}"
    case camera_alt = "\u{ea88}"
    case camera_front = "\u{ea89}"
    case camera_rear = "\u{ea8a}"
    case camera_roll = "\u{ea8b}"
    case center_focus_strong = "\u{ea8c}"
    case center_focus_weak = "\u{ea8d}"
    case collections = "\u{ea8e}"
    case color_lens = "\u{ea8f}"
    case colorize = "\u{ea90}"
    case compare = "\u{ea91}"
    case control_point_duplicate = "\u{ea92}"
    case crop_16_9 = "\u{ea93}"
    case crop_3_2 = "\u{ea94}"
    case crop = "\u{ea95}"
    case crop_5_4 = "\u{ea96}"
    case crop_7_5 = "\u{ea97}"
    case crop_din = "\u{ea98}"
    case crop_free = "\u{ea99}"
    case crop_original = "\u{ea9a}"
    case crop_portrait = "\u{ea9b}"
    case crop_square = "\u{ea9c}"
    case dehaze = "\u{ea9d}"
    case details = "\u{ea9e}"
    case exposure = "\u{ea9f}"
    case exposure_minus_1 = "\u{eaa0}"
    case exposure_minus_2 = "\u{eaa1}"
    case exposure_plus_1 = "\u{eaa2}"
    case exposure_plus_2 = "\u{eaa3}"
    case exposure_zero = "\u{eaa4}"
    case filter_1 = "\u{eaa5}"
    case filter_2 = "\u{eaa6}"
    case filter_3 = "\u{eaa7}"
    case filter = "\u{eaa8}"
    case filter_4 = "\u{eaa9}"
    case filter_5 = "\u{eaaa}"
    case filter_6 = "\u{eaab}"
    case filter_7 = "\u{eaac}"
    case filter_8 = "\u{eaad}"
    case filter_9 = "\u{eaae}"
    case filter_9_plus = "\u{eaaf}"
    case filter_b_and_w = "\u{eab0}"
    case filter_center_focus = "\u{eab1}"
    case filter_drama = "\u{eab2}"
    case filter_frames = "\u{eab3}"
    case filter_hdr = "\u{eab4}"
    case filter_none = "\u{eab5}"
    case filter_tilt_shift = "\u{eab6}"
    case filter_vintage = "\u{eab7}"
    case flare = "\u{eab8}"
    case flash_auto = "\u{eab9}"
    case flash_off = "\u{eaba}"
    case flash_on = "\u{eabb}"
    case flip = "\u{eabc}"
    case gradient = "\u{eabd}"
    case grain = "\u{eabe}"
    case grid_off = "\u{eabf}"
    case grid_on = "\u{eac0}"
    case hdr_off = "\u{eac1}"
    case hdr_on = "\u{eac2}"
    case hdr_strong = "\u{eac3}"
    case hdr_weak = "\u{eac4}"
    case healing = "\u{eac5}"
    case image_aspect_ratio = "\u{eac6}"
    case iso = "\u{eac7}"
    case leak_add = "\u{eac8}"
    case leak_remove = "\u{eac9}"
    case lens = "\u{eaca}"
    case looks_3 = "\u{eacb}"
    case looks = "\u{eacc}"
    case looks_4 = "\u{eacd}"
    case looks_5 = "\u{eace}"
    case looks_6 = "\u{eacf}"
    case looks_one = "\u{ead0}"
    case looks_two = "\u{ead1}"
    case loupe = "\u{ead2}"
    case monochrome_photos = "\u{ead3}"
    case music_note = "\u{ead4}"
    case nature = "\u{ead5}"
    case nature_people = "\u{ead6}"
    case navigate_before = "\u{ead7}"
    case navigate_next = "\u{ead8}"
    case panorama = "\u{ead9}"
    case panorama_fish_eye = "\u{eada}"
    case panorama_horizontal = "\u{eadb}"
    case panorama_vertical = "\u{eadc}"
    case panorama_wide_angle = "\u{eadd}"
    case photo_album = "\u{eade}"
    case picture_as_pdf = "\u{eadf}"
    case portrait = "\u{eae0}"
    case remove_red_eye = "\u{eae1}"
    case rotate_90_degrees_ccw = "\u{eae2}"
    case rotate_left = "\u{eae3}"
    case rotate_right = "\u{eae4}"
    case slideshow = "\u{eae5}"
    case straighten = "\u{eae6}"
    case style = "\u{eae7}"
    case switch_camera = "\u{eae8}"
    case switch_video = "\u{eae9}"
    case texture = "\u{eaea}"
    case timelapse = "\u{eaeb}"
    case timer_10 = "\u{eaec}"
    case timer_3 = "\u{eaed}"
    case timer = "\u{eaee}"
    case timer_off = "\u{eaef}"
    case tonality = "\u{eaf0}"
    case transform = "\u{eaf1}"
    case tune = "\u{eaf2}"
    case view_comfortable = "\u{eaf3}"
    case view_compact = "\u{eaf4}"
    case wb_auto = "\u{eaf5}"
    case wb_cloudy = "\u{eaf6}"
    case wb_incandescent = "\u{eaf7}"
    case wb_sunny = "\u{eaf8}"
    case collections_bookmark = "\u{eaf9}"
    case photo_size_select_actual = "\u{eafa}"
    case photo_size_select_large = "\u{eafb}"
    case photo_size_select_small = "\u{eafc}"
    case vignette = "\u{eafd}"
    case wb_iridescent = "\u{eafe}"
    case crop_rotate = "\u{eaff}"
    case linked_camera = "\u{eb00}"
    case add_a_photo = "\u{eb01}"
    case movie_filter = "\u{eb02}"
    case photo_filter = "\u{eb03}"
    case burst_mode = "\u{eb04}"
    case shutter_speed = "\u{eb05}"
    case add_photo_alternate = "\u{eb06}"
    case image_search = "\u{eb07}"
    case music_off = "\u{eb08}"
    case beenhere = "\u{eb09}"
    case directions = "\u{eb0a}"
    case directions_bike = "\u{eb0b}"
    case directions_bus = "\u{eb0c}"
    case directions_car = "\u{eb0d}"
    case directions_ferry = "\u{eb0e}"
    case directions_subway = "\u{eb0f}"
    case directions_railway = "\u{eb10}"
    case directions_walk = "\u{eb11}"
    case hotel = "\u{eb12}"
    case layers = "\u{eb13}"
    case layers_clear = "\u{eb14}"
    case local_atm = "\u{eb15}"
    case local_attraction = "\u{eb16}"
    case local_bar = "\u{eb17}"
    case local_cafe = "\u{eb18}"
    case local_car_wash = "\u{eb19}"
    case local_convenience_store = "\u{eb1a}"
    case local_drink = "\u{eb1b}"
    case local_florist = "\u{eb1c}"
    case local_gas_station = "\u{eb1d}"
    case local_grocery_store = "\u{eb1e}"
    case local_hospital = "\u{eb1f}"
    case local_laundry_service = "\u{eb20}"
    case local_library = "\u{eb21}"
    case local_mall = "\u{eb22}"
    case local_movies = "\u{eb23}"
    case local_offer = "\u{eb24}"
    case local_parking = "\u{eb25}"
    case local_pharmacy = "\u{eb26}"
    case local_pizza = "\u{eb27}"
    case local_print_shop = "\u{eb28}"
    case local_restaurant = "\u{eb29}"
    case local_shipping = "\u{eb2a}"
    case local_taxi = "\u{eb2b}"
    case location_history = "\u{eb2c}"
    case map = "\u{eb2d}"
    case navigation = "\u{eb2e}"
    case pin_drop = "\u{eb2f}"
    case rate_review = "\u{eb30}"
    case satellite = "\u{eb31}"
    case store_mall_directory = "\u{eb32}"
    case traffic = "\u{eb33}"
    case directions_run = "\u{eb34}"
    case add_location = "\u{eb35}"
    case edit_location = "\u{eb36}"
    case near_me = "\u{eb37}"
    case person_pin_circle = "\u{eb38}"
    case zoom_out_map = "\u{eb39}"
    case restaurant = "\u{eb3a}"
    case ev_station = "\u{eb3b}"
    case streetview = "\u{eb3c}"
    case subway = "\u{eb3d}"
    case train = "\u{eb3e}"
    case tram = "\u{eb3f}"
    case transfer_within_a_station = "\u{eb40}"
    case atm = "\u{eb41}"
    case category = "\u{eb42}"
    case not_listed_location = "\u{eb43}"
    case departure_board = "\u{eb44}"
    case edit_attributes = "\u{eb46}"
    case transit_enterexit = "\u{eb47}"
    case fastfood = "\u{eb48}"
    case trip_origin = "\u{eb49}"
    case compass_calibration = "\u{eb4a}"
    case money = "\u{eb4b}"
    case apps = "\u{eb4c}"
    case arrow_back = "\u{eb4d}"
    case arrow_drop_down = "\u{eb4e}"
    case arrow_drop_down_circle = "\u{eb4f}"
    case arrow_drop_up = "\u{eb50}"
    case arrow_forward = "\u{eb51}"
    case cancel = "\u{eb52}"
    case check = "\u{eb53}"
    case expand_less = "\u{eb54}"
    case expand_more = "\u{eb55}"
    case fullscreen = "\u{eb56}"
    case fullscreen_exit = "\u{eb57}"
    case menu = "\u{eb58}"
    case keyboard_control = "\u{eb59}"
    case more_vert = "\u{eb5a}"
    case refresh = "\u{eb5b}"
    case unfold_less = "\u{eb5c}"
    case unfold_more = "\u{eb5d}"
    case arrow_upward = "\u{eb5e}"
    case subdirectory_arrow_left = "\u{eb5f}"
    case subdirectory_arrow_right = "\u{eb60}"
    case arrow_downward = "\u{eb61}"
    case first_page = "\u{eb62}"
    case last_page = "\u{eb63}"
    case arrow_left = "\u{eb64}"
    case arrow_right = "\u{eb65}"
    case arrow_back_ios = "\u{eb66}"
    case arrow_forward_ios = "\u{eb67}"
    case adb = "\u{eb68}"
    case disc_full = "\u{eb69}"
    case do_not_disturb_alt = "\u{eb6a}"
    case drive_eta = "\u{eb6b}"
    case event_available = "\u{eb6c}"
    case event_busy = "\u{eb6d}"
    case event_note = "\u{eb6e}"
    case folder_special = "\u{eb6f}"
    case mms = "\u{eb70}"
    case more = "\u{eb71}"
    case network_locked = "\u{eb72}"
    case phone_bluetooth_speaker = "\u{eb73}"
    case phone_forwarded = "\u{eb74}"
    case phone_in_talk = "\u{eb75}"
    case phone_locked = "\u{eb76}"
    case phone_missed = "\u{eb77}"
    case phone_paused = "\u{eb78}"
    case sim_card_alert = "\u{eb79}"
    case sms_failed = "\u{eb7a}"
    case sync_disabled = "\u{eb7b}"
    case sync_problem = "\u{eb7c}"
    case system_update = "\u{eb7d}"
    case tap_and_play = "\u{eb7e}"
    case vibration = "\u{eb7f}"
    case voice_chat = "\u{eb80}"
    case vpn_lock = "\u{eb81}"
    case airline_seat_flat = "\u{eb82}"
    case airline_seat_flat_angled = "\u{eb83}"
    case airline_seat_individual_suite = "\u{eb84}"
    case airline_seat_legroom_extra = "\u{eb85}"
    case airline_seat_legroom_normal = "\u{eb86}"
    case airline_seat_legroom_reduced = "\u{eb87}"
    case airline_seat_recline_extra = "\u{eb88}"
    case airline_seat_recline_normal = "\u{eb89}"
    case confirmation_number = "\u{eb8a}"
    case live_tv = "\u{eb8b}"
    case ondemand_video = "\u{eb8c}"
    case personal_video = "\u{eb8d}"
    case power = "\u{eb8e}"
    case wc = "\u{eb8f}"
    case wifi = "\u{eb90}"
    case enhanced_encryption = "\u{eb91}"
    case network_check = "\u{eb92}"
    case no_encryption = "\u{eb93}"
    case rv_hookup = "\u{eb94}"
    case do_not_disturb_off = "\u{eb95}"
    case priority_high = "\u{eb96}"
    case power_off = "\u{eb97}"
    case tv_off = "\u{eb98}"
    case wifi_off = "\u{eb99}"
    case phone_callback = "\u{eb9a}"
    case pie_chart = "\u{eb9b}"
    case pie_chart_outlined = "\u{eb9c}"
    case bubble_chart = "\u{eb9d}"
    case multiline_chart = "\u{eb9e}"
    case show_chart = "\u{eb9f}"
    case cake = "\u{eba0}"
    case group = "\u{eba1}"
    case group_add = "\u{eba2}"
    case location_city = "\u{eba3}"
    case mood_bad = "\u{eba4}"
    case notifications = "\u{eba5}"
    case notifications_none = "\u{eba6}"
    case notifications_off = "\u{eba7}"
    case notifications_active = "\u{eba8}"
    case notifications_paused = "\u{eba9}"
    case pages = "\u{ebaa}"
    case party_mode = "\u{ebab}"
    case people_outline = "\u{ebac}"
    case person = "\u{ebad}"
    case person_add = "\u{ebae}"
    case person_outline = "\u{ebaf}"
    case plus_one = "\u{ebb0}"
    case `public` = "\u{ebb1}"
    case school = "\u{ebb2}"
    case share = "\u{ebb3}"
    case whatshot = "\u{ebb4}"
    case sentiment_dissatisfied = "\u{ebb5}"
    case sentiment_neutral = "\u{ebb6}"
    case sentiment_satisfied = "\u{ebb7}"
    case sentiment_very_dissatisfied = "\u{ebb8}"
    case sentiment_very_satisfied = "\u{ebb9}"
    case thumb_down_alt = "\u{ebba}"
    case thumb_up_alt = "\u{ebbb}"
    case check_box = "\u{ebbc}"
    case check_box_outline_blank = "\u{ebbd}"
    case radio_button_checked = "\u{ebbe}"
    case star = "\u{ebbf}"
    case star_half = "\u{ebc0}"
    case star_outline = "\u{ebc1}"
    case accessibility = "\u{ebc3}"
    case account_balance = "\u{ebc4}"
    case account_balance_wallet = "\u{ebc5}"
    case account_box = "\u{ebc6}"
    case account_circle = "\u{ebc7}"
    case add_shopping_cart = "\u{ebc8}"
    case alarm_off = "\u{ebc9}"
    case alarm_on = "\u{ebca}"
    case android = "\u{ebcb}"
    case announcement = "\u{ebcc}"
    case aspect_ratio = "\u{ebcd}"
    case assignment = "\u{ebce}"
    case assignment_ind = "\u{ebcf}"
    case assignment_late = "\u{ebd0}"
    case assignment_return = "\u{ebd1}"
    case assignment_returned = "\u{ebd2}"
    case assignment_turned_in = "\u{ebd3}"
    case autorenew = "\u{ebd4}"
    case book = "\u{ebd5}"
    case bookmark = "\u{ebd6}"
    case bookmark_outline = "\u{ebd7}"
    case bug_report = "\u{ebd8}"
    case build = "\u{ebd9}"
    case cached = "\u{ebda}"
    case change_history = "\u{ebdb}"
    case check_circle = "\u{ebdc}"
    case chrome_reader_mode = "\u{ebdd}"
    case code = "\u{ebde}"
    case credit_card = "\u{ebdf}"
    case dashboard = "\u{ebe0}"
    case delete = "\u{ebe1}"
    case description = "\u{ebe2}"
    case dns = "\u{ebe3}"
    case done = "\u{ebe4}"
    case done_all = "\u{ebe5}"
    case exit_to_app = "\u{ebe6}"
    case explore = "\u{ebe7}"
    case `extension` = "\u{ebe8}"
    case face = "\u{ebe9}"
    case favorite = "\u{ebea}"
    case favorite_outline = "\u{ebeb}"
    case find_in_page = "\u{ebec}"
    case find_replace = "\u{ebed}"
    case flip_to_back = "\u{ebee}"
    case flip_to_front = "\u{ebef}"
    case group_work = "\u{ebf0}"
    case help = "\u{ebf1}"
    case highlight_remove = "\u{ebf2}"
    case history = "\u{ebf3}"
    case home = "\u{ebf4}"
    case hourglass_empty = "\u{ebf5}"
    case hourglass_full = "\u{ebf6}"
    case https = "\u{ebf7}"
    case info = "\u{ebf8}"
    case info_outline = "\u{ebf9}"
    case input = "\u{ebfa}"
    case invert_colors_on = "\u{ebfb}"
    case label = "\u{ebfc}"
    case label_outline = "\u{ebfd}"
    case language = "\u{ebfe}"
    case launch = "\u{ebff}"
    case list = "\u{ec00}"
    case lock_open = "\u{ec01}"
    case lock_outline = "\u{ec02}"
    case loyalty = "\u{ec03}"
    case markunread_mailbox = "\u{ec04}"
    case note_add = "\u{ec05}"
    case open_in_browser = "\u{ec06}"
    case open_with = "\u{ec07}"
    case pageview = "\u{ec08}"
    case perm_camera_mic = "\u{ec09}"
    case perm_contact_calendar = "\u{ec0a}"
    case perm_data_setting = "\u{ec0b}"
    case perm_device_information = "\u{ec0c}"
    case perm_media = "\u{ec0d}"
    case perm_phone_msg = "\u{ec0e}"
    case perm_scan_wifi = "\u{ec0f}"
    case picture_in_picture = "\u{ec10}"
    case polymer = "\u{ec11}"
    case power_settings_new = "\u{ec12}"
    case receipt = "\u{ec13}"
    case redeem = "\u{ec14}"
    case search = "\u{ec15}"
    case settings = "\u{ec16}"
    case settings_applications = "\u{ec17}"
    case settings_backup_restore = "\u{ec18}"
    case settings_bluetooth = "\u{ec19}"
    case settings_cell = "\u{ec1a}"
    case settings_brightness = "\u{ec1b}"
    case settings_ethernet = "\u{ec1c}"
    case settings_input_antenna = "\u{ec1d}"
    case settings_input_component = "\u{ec1e}"
    case settings_input_hdmi = "\u{ec1f}"
    case settings_input_svideo = "\u{ec20}"
    case settings_overscan = "\u{ec21}"
    case settings_phone = "\u{ec22}"
    case settings_power = "\u{ec23}"
    case settings_remote = "\u{ec24}"
    case settings_voice = "\u{ec25}"
    case shop = "\u{ec26}"
    case shop_two = "\u{ec27}"
    case shopping_basket = "\u{ec28}"
    case speaker_notes = "\u{ec29}"
    case spellcheck = "\u{ec2a}"
    case stars = "\u{ec2b}"
    case subject = "\u{ec2c}"
    case supervisor_account = "\u{ec2d}"
    case swap_horiz = "\u{ec2e}"
    case swap_vert = "\u{ec2f}"
    case swap_vertical_circle = "\u{ec30}"
    case system_update_alt = "\u{ec31}"
    case tab = "\u{ec32}"
    case tab_unselected = "\u{ec33}"
    case thumb_down = "\u{ec34}"
    case thumb_up = "\u{ec35}"
    case thumbs_up_down = "\u{ec36}"
    case toc = "\u{ec37}"
    case today = "\u{ec38}"
    case toll = "\u{ec39}"
    case track_changes = "\u{ec3a}"
    case translate = "\u{ec3b}"
    case trending_down = "\u{ec3c}"
    case trending_neutral = "\u{ec3d}"
    case trending_up = "\u{ec3e}"
    case verified_user = "\u{ec3f}"
    case view_agenda = "\u{ec40}"
    case view_array = "\u{ec41}"
    case view_carousel = "\u{ec42}"
    case view_column = "\u{ec43}"
    case view_day = "\u{ec44}"
    case view_headline = "\u{ec45}"
    case view_list = "\u{ec46}"
    case view_module = "\u{ec47}"
    case view_quilt = "\u{ec48}"
    case view_stream = "\u{ec49}"
    case view_week = "\u{ec4a}"
    case visibility_off = "\u{ec4b}"
    case card_membership = "\u{ec4c}"
    case card_travel = "\u{ec4d}"
    case work = "\u{ec4e}"
    case youtube_searched_for = "\u{ec4f}"
    case eject = "\u{ec50}"
    case camera_enhance = "\u{ec51}"
    case help_outline = "\u{ec52}"
    case reorder = "\u{ec53}"
    case zoom_in = "\u{ec54}"
    case zoom_out = "\u{ec55}"
    case http = "\u{ec56}"
    case event_seat = "\u{ec57}"
    case flight_land = "\u{ec58}"
    case flight_takeoff = "\u{ec59}"
    case play_for_work = "\u{ec5a}"
    case gif = "\u{ec5b}"
    case indeterminate_check_box = "\u{ec5c}"
    case offline_pin = "\u{ec5d}"
    case all_out = "\u{ec5e}"
    case copyright = "\u{ec5f}"
    case fingerprint = "\u{ec60}"
    case gavel = "\u{ec61}"
    case lightbulb_outline = "\u{ec62}"
    case picture_in_picture_alt = "\u{ec63}"
    case important_devices = "\u{ec64}"
    case touch_app = "\u{ec65}"
    case accessible = "\u{ec66}"
    case compare_arrows = "\u{ec67}"
    case date_range = "\u{ec68}"
    case donut_large = "\u{ec69}"
    case donut_small = "\u{ec6a}"
    case line_style = "\u{ec6b}"
    case line_weight = "\u{ec6c}"
    case motorcycle = "\u{ec6d}"
    case opacity = "\u{ec6e}"
    case pets = "\u{ec6f}"
    case pregnant_woman = "\u{ec70}"
    case record_voice_over = "\u{ec71}"
    case rounded_corner = "\u{ec72}"
    case rowing = "\u{ec73}"
    case timeline = "\u{ec74}"
    case update = "\u{ec75}"
    case watch_later = "\u{ec76}"
    case pan_tool = "\u{ec77}"
    case euro_symbol = "\u{ec78}"
    case g_translate = "\u{ec79}"
    case remove_shopping_cart = "\u{ec7a}"
    case restore_page = "\u{ec7b}"
    case speaker_notes_off = "\u{ec7c}"
    case delete_forever = "\u{ec7d}"
    case accessibility_new = "\u{ec7e}"
    case check_circle_outline = "\u{ec7f}"
    case delete_outline = "\u{ec80}"
    case done_outline = "\u{ec81}"
    case maximize = "\u{ec82}"
    case minimize = "\u{ec83}"
    case offline_bolt = "\u{ec84}"
    case swap_horizontal_circle = "\u{ec85}"
    case accessible_forward = "\u{ec86}"
    case calendar_today = "\u{ec87}"
    case calendar_view_day = "\u{ec88}"
    case label_important = "\u{ec89}"
    case restore_from_trash = "\u{ec8a}"
    case supervised_user_circle = "\u{ec8b}"
    case text_rotate_up = "\u{ec8c}"
    case text_rotate_vertical = "\u{ec8d}"
    case text_rotation_angledown = "\u{ec8e}"
    case text_rotation_angleup = "\u{ec8f}"
    case text_rotation_down = "\u{ec90}"
    case text_rotation_none = "\u{ec91}"
    case commute = "\u{ec92}"
    case arrow_right_alt = "\u{ec93}"
    case work_off = "\u{ec94}"
    case work_outline = "\u{ec95}"
    case drag_indicator = "\u{ec96}"
    case horizontal_split = "\u{ec97}"
    case label_important_outline = "\u{ec98}"
    case vertical_split = "\u{ec99}"
    case voice_over_off = "\u{ec9a}"
    case segment = "\u{ec9b}"
    case contact_support = "\u{ec9c}"
    case compress = "\u{ec9d}"
    case filter_list_alt = "\u{ec9e}"
    case expand = "\u{ec9f}"
    case edit_off = "\u{eca0}"
    case account_tree = "\u{ecca}"
    case add_chart = "\u{eccb}"
    case add_ic_call = "\u{eccc}"
    case add_moderator = "\u{eccd}"
    case all_inbox = "\u{ecce}"
    case approval = "\u{eccf}"
    case assistant_direction = "\u{ecd0}"
    case assistant_navigation = "\u{ecd1}"
    case bookmarks = "\u{ecd2}"
    case bus_alert = "\u{ecd3}"
    case cases = "\u{ecd4}"
    case circle_notifications = "\u{ecd5}"
    case closed_caption_off = "\u{ecd6}"
    case connected_tv = "\u{ecd7}"
    case dangerous = "\u{ecd8}"
    case dashboard_customize = "\u{ecd9}"
    case desktop_access_disabled = "\u{ecda}"
    case drive_file_move_outline = "\u{ecdb}"
    case drive_file_rename_outline = "\u{ecdc}"
    case drive_folder_upload = "\u{ecdd}"
    case duo = "\u{ecde}"
    case explore_off = "\u{ecdf}"
    case file_download_done = "\u{ece0}"
    case rtt = "\u{ece1}"
    case grid_view = "\u{ece2}"
    case hail = "\u{ece3}"
    case home_filled = "\u{ece4}"
    case imagesearch_roller = "\u{ece5}"
    case label_off = "\u{ece6}"
    case library_add_check = "\u{ece7}"
    case logout = "\u{ece8}"
    case margin = "\u{ece9}"
    case mark_as_unread = "\u{ecea}"
    case menu_open = "\u{eceb}"
    case mp = "\u{ecec}"
    case offline_share = "\u{eced}"
    case padding = "\u{ecee}"
    case panorama_photosphere = "\u{ecef}"
    case panorama_photosphere_select = "\u{ecf0}"
    case person_add_disabled = "\u{ecf1}"
    case phone_disabled = "\u{ecf2}"
    case phone_enabled = "\u{ecf3}"
    case pivot_table_chart = "\u{ecf4}"
    case print_disabled = "\u{ecf5}"
    case railway_alert = "\u{ecf6}"
    case recommend = "\u{ecf7}"
    case remove_done = "\u{ecf8}"
    case remove_moderator = "\u{ecf9}"
    case repeat_on = "\u{ecfa}"
    case repeat_one_on = "\u{ecfb}"
    case replay_circle_filled = "\u{ecfc}"
    case reset_tv = "\u{ecfd}"
    case sd = "\u{ecfe}"
    case shield = "\u{ecff}"
    case shuffle_on = "\u{ed00}"
    case speed = "\u{ed01}"
    case stacked_bar_chart = "\u{ed02}"
    case stream = "\u{ed03}"
    case swipe = "\u{ed04}"
    case switch_account = "\u{ed05}"
    case tag = "\u{ed06}"
    case thumb_down_off_alt = "\u{ed07}"
    case thumb_up_off_alt = "\u{ed08}"
    case toggle_off = "\u{ed09}"
    case toggle_on = "\u{ed0a}"
    case two_wheeler = "\u{ed0b}"
    case upload_file = "\u{ed0c}"
    case view_in_ar = "\u{ed0d}"
    case waterfall_chart = "\u{ed0e}"
    case wb_shade = "\u{ed0f}"
    case wb_twighlight = "\u{ed10}"
    case home_work = "\u{ed11}"
    case schedule_send = "\u{ed12}"
    case bolt = "\u{ed13}"
    case send_and_archive = "\u{ed14}"
    case workspaces_filled = "\u{ed15}"
    case file_present = "\u{ed16}"
    case workspaces_outline = "\u{ed17}"
    case fit_screen = "\u{ed18}"
    case saved_search = "\u{ed19}"
    case storefront = "\u{ed1a}"
    case amp_stories = "\u{ed1b}"
    case dynamic_feed = "\u{ed1c}"
    case euro = "\u{ed1d}"
    case height = "\u{ed1e}"
    case policy = "\u{ed1f}"
    case sync_alt = "\u{ed20}"
    case menu_book = "\u{ed21}"
    case emoji_flags = "\u{ed22}"
    case emoji_food_beverage = "\u{ed23}"
    case emoji_nature = "\u{ed24}"
    case emoji_people = "\u{ed25}"
    case emoji_symbols = "\u{ed26}"
    case emoji_transportation = "\u{ed27}"
    case post_add = "\u{ed28}"
    case people_alt = "\u{ed29}"
    case emoji_emotions = "\u{ed2a}"
    case emoji_events = "\u{ed2b}"
    case emoji_objects = "\u{ed2c}"
    case sports_basketball = "\u{ed2d}"
    case sports_cricket = "\u{ed2e}"
    case sports_esports = "\u{ed2f}"
    case sports_football = "\u{ed30}"
    case sports_golf = "\u{ed31}"
    case sports_hockey = "\u{ed32}"
    case sports_mma = "\u{ed33}"
    case sports_motorsports = "\u{ed34}"
    case sports_rugby = "\u{ed35}"
    case sports_soccer = "\u{ed36}"
    case sports = "\u{ed37}"
    case sports_volleyball = "\u{ed38}"
    case sports_tennis = "\u{ed39}"
    case sports_handball = "\u{ed3a}"
    case sports_kabaddi = "\u{ed3b}"
    case eco = "\u{ed3c}"
    case museum = "\u{ed3d}"
    case flip_camera_android = "\u{ed3e}"
    case flip_camera_ios = "\u{ed3f}"
    case cancel_schedule_send = "\u{ed40}"
    case apartment = "\u{ed41}"
    case bathtub = "\u{ed42}"
    case deck = "\u{ed43}"
    case fireplace = "\u{ed44}"
    case house = "\u{ed45}"
    case king_bed = "\u{ed46}"
    case nights_stay = "\u{ed47}"
    case outdoor_grill = "\u{ed48}"
    case single_bed = "\u{ed49}"
    case square_foot = "\u{ed4a}"
    case double_arrow = "\u{ed4b}"
    case sports_baseball = "\u{ed4c}"
    case attractions = "\u{ed4d}"
    case bakery_dining = "\u{ed4e}"
    case breakfast_dining = "\u{ed4f}"
    case car_rental = "\u{ed50}"
    case car_repair = "\u{ed51}"
    case dinner_dining = "\u{ed52}"
    case dry_cleaning = "\u{ed53}"
    case hardware = "\u{ed54}"
    case liquor = "\u{ed55}"
    case lunch_dining = "\u{ed56}"
    case nightlife = "\u{ed57}"
    case park = "\u{ed58}"
    case ramen_dining = "\u{ed59}"
    case celebration = "\u{ed5a}"
    case theater_comedy = "\u{ed5b}"
    case badge = "\u{ed5c}"
    case festival = "\u{ed5d}"
    case icecream = "\u{ed5e}"
    case volunteer_activism = "\u{ed5f}"
    case contactless = "\u{ed60}"
    case delivery_dining = "\u{ed61}"
    case brunch_dining = "\u{ed62}"
    case takeout_dining = "\u{ed63}"
    case ac_unit = "\u{ed64}"
    case airport_shuttle = "\u{ed65}"
    case all_inclusive = "\u{ed66}"
    case beach_access = "\u{ed67}"
    case business_center = "\u{ed68}"
    case casino = "\u{ed69}"
    case child_care = "\u{ed6a}"
    case child_friendly = "\u{ed6b}"
    case fitness_center = "\u{ed6c}"
    case golf_course = "\u{ed6d}"
    case hot_tub = "\u{ed6e}"
    case kitchen = "\u{ed6f}"
    case pool = "\u{ed70}"
    case room_service = "\u{ed71}"
    case smoke_free = "\u{ed72}"
    case smoking_rooms = "\u{ed73}"
    case spa = "\u{ed74}"
    case no_meeting_room = "\u{ed75}"
    case meeting_room = "\u{ed76}"
    case goat = "\u{ed77}"
}
