//
//  Resources.swift
//  Flamingo
//
//  Native replacement for R.swift - Type-safe resource references
//

import UIKit

// MARK: - R Namespace

enum R {
    enum image {
        static func color_gradient() -> UIImage? {
            UIImage(named: "color_gradient")
        }
        
        static func color_gradient_blue() -> UIImage? {
            UIImage(named: "color_gradient_blue")
        }
        
        static func flamingoBack() -> UIImage? {
            UIImage(named: "flamingo-back")
        }
        
        static func circle() -> UIImage? {
            UIImage(named: "circle")
        }
    }
    
    enum color {
        static func primary() -> UIColor? {
            UIColor(named: "primary")
        }
        
        static func secondary() -> UIColor? {
            UIColor(named: "secondary")
        }
    }
    
    enum file {
        static func sourcesJson() -> URL? {
            Bundle.main.url(forResource: "sources", withExtension: "json")
        }
    }
    
    enum storyboard {
        enum main {
            static func instantiateInitialViewController() -> UIViewController? {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                return storyboard.instantiateInitialViewController()
            }
        }
        
        enum articleList {
            private static var storyboard: UIStoryboard {
                UIStoryboard(name: "ArticleList", bundle: nil)
            }
            
            static func articleListVC() -> ArticleListVC? {
                storyboard.instantiateViewController(withIdentifier: "ArticleListVC") as? ArticleListVC
            }
        }
        
        enum settingsVC {
            private static var storyboard: UIStoryboard {
                UIStoryboard(name: "SettingsVC", bundle: nil)
            }
            
            static func settingsVC() -> SettingsVC? {
                storyboard.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC
            }
        }
    }
    
    enum reuseIdentifier {
        static let articleDefaultCell = "ArticleDefaultCell"
        static let commentCell = "CommentCell"
        static let switchTableCell = "SwitchTableCell"
        static let simpleTableCell = "SimpleTableCell"
        static let titleSeparatorCell = "TitleSeparatorCell"
    }
    
    enum segue {
        enum articleListVC {
            static let comments = "comments"
        }
    }
    
    enum string {
        enum localizable {
            static func commonOk() -> String { NSLocalizedString("Common/Ok", comment: "") }
            static func commonSave() -> String { NSLocalizedString("Common/Save", comment: "") }
            static func commonCancel() -> String { NSLocalizedString("Common/Cancel", comment: "") }
            static func commonError() -> String { NSLocalizedString("Common/Error", comment: "") }
            static func commonStop() -> String { NSLocalizedString("Common/Stop", comment: "") }
            static func commonDone() -> String { NSLocalizedString("Common/Done", comment: "") }
            static func commonNext() -> String { NSLocalizedString("Common/Next", comment: "") }
            static func commonShare() -> String { NSLocalizedString("Common/Share", comment: "") }
            static func commonContinue() -> String { NSLocalizedString("Common/Continue", comment: "") }
            static func commonResume() -> String { NSLocalizedString("Common/Resume", comment: "") }
            static func commonConfirm() -> String { NSLocalizedString("Common/Confirm", comment: "") }
            static func commonSelect() -> String { NSLocalizedString("Common/Select", comment: "") }
            static func commonDelete() -> String { NSLocalizedString("Common/Delete", comment: "") }
            static func commonMove() -> String { NSLocalizedString("Common/Move", comment: "") }
            static func commonExport() -> String { NSLocalizedString("Common/Export", comment: "") }
            static func commonYes() -> String { NSLocalizedString("Common/Yes", comment: "") }
            static func commonNo() -> String { NSLocalizedString("Common/No", comment: "") }
            
            static func errorUnknown() -> String { NSLocalizedString("Error/Unknown", comment: "") }
            
            static func articlesListLoadingFailed() -> String { NSLocalizedString("ArticlesList/LoadingFailed", comment: "") }
            
            static func articleCommentsLoading() -> String { NSLocalizedString("ArticleComments/Loading", comment: "") }
            static func articleCommentsLoadingFailed() -> String { NSLocalizedString("ArticleComments/LoadingFailed", comment: "") }
            static func articleCommentsCommentAnonymous() -> String { NSLocalizedString("ArticleComments/Comment/Anonymous", comment: "") }
            
            static func flamingoErrorUnknown() -> String { NSLocalizedString("FlamingoError/Unknown", comment: "") }
            static func flamingoErrorNothingToShow() -> String { NSLocalizedString("FlamingoError/NothingToShow", comment: "") }
            static func flamingoErrorSourcesNotConfigured() -> String { NSLocalizedString("FlamingoError/SourcesNotConfigured", comment: "") }
            
            static func settings_general_theme_auto() -> String { NSLocalizedString("settings_general_theme_auto", comment: "") }
            static func settings_general_theme_dark() -> String { NSLocalizedString("settings_general_theme_dark", comment: "") }
            static func settings_general_theme_light() -> String { NSLocalizedString("settings_general_theme_light", comment: "") }
        }
    }
}

// MARK: - Convenience Alias

let i18n = R.string.localizable.self
