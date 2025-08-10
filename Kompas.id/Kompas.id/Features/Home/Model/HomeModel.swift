//
//  HomeModel.swift
//  Kompas.id
//
//  Created by Farhan on 03/08/25.
//

import Foundation

struct BreakingNewsResponse: Codable {
    let headline: String
    let subheadline: String
    let publishedTime: String
    let articles: [GenericArticle]
    let source: String
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case headline
        case subheadline
        case publishedTime = "published_time"
        case articles
        case source
        case image
    }
}

struct LiveReportResponse: Codable {
    let reportType: String
    let mainArticle: MainArticle
    let relatedArticles: [RelatedArticle]
    let moreReports: MoreReports
    let featuredArticles: [FeaturedArticle]
    
    enum CodingKeys: String, CodingKey {
        case reportType = "report_type"
        case mainArticle = "main_article"
        case relatedArticles = "related_articles"
        case moreReports = "more_reports"
        case featuredArticles = "featured_articles"
    }
}

struct MainArticle: Codable {
    let category: String
    let title: String
    let image: String?
    let publishedTime: String
    
    enum CodingKeys: String, CodingKey {
        case category
        case title
        case image
        case publishedTime = "published_time"
    }
}

struct RelatedArticle: Codable {
    let title: String
    let publishedTime: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case publishedTime = "published_time"
    }
}

struct MoreReports: Codable {
    let label: String
    let count: String
}

struct FeaturedArticle: Codable {
    let title: String
    let image: String?
}

struct IframeCampaignResponse: Codable {
    let title: String
    let subtitle: String
    let iframeUrl: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case iframeUrl = "url"
    }
}

struct HotTopic: Codable {
    let title: String
    let imageDescription: String
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case imageDescription = "image_description"
        case image
    }
}

struct HotTopicsResponse: Codable {
    let section: String
    let topics: [HotTopic]
}

struct ReusableArticleSection: Codable {
    let section: String
    let articles: [GenericArticle]
}

struct ArticleWithDescription: Codable {
    let title: String
    let description: String?
    let imageDescription: String?
    let mediaCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case imageDescription = "image_description"
        case mediaCount = "media_count"
    }
}

struct GenericArticle: Codable {
    let id: String?
    let title: String
    let publishedTime: String?
    let description: String?
    let imageDescription: String?
    let mediaCount: Int?
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case publishedTime = "published_time"
        case description
        case imageDescription = "image_description"
        case mediaCount = "media_count"
        case image
    }
    
    func generateID() -> String {
        return "\(title)_\(publishedTime ?? "")".replacingOccurrences(of: " ", with: "_")
    }
}

struct HomeSectionData: Codable {
    let type: HomeSectionType
    let title: String?
    let data: DynamicSectionData?
}

enum HomeSectionType: String, Codable {
    case breakingNews = "breaking_news"
    case liveReport = "live_report"
    case iframeCampaign = "iframe_campaign"
    case hotTopics = "hot_topics"
    case articles = "articles"
}

enum DynamicSectionData: Codable {
    case breakingNews(BreakingNewsResponse)
    case liveReport(LiveReportResponse)
    case iframeCampaign(IframeCampaignResponse)
    case hotTopics(HotTopicsResponse)
    case articles([GenericArticle])
    
    enum CodingKeys: String, CodingKey {
        case breakingNews = "breaking_news"
        case liveReport = "live_report"
        case iframeCampaign = "iframe_campaign"
        case hotTopics = "hot_topics"
        case articles = "articles"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let breakingNews = try container.decodeIfPresent(BreakingNewsResponse.self, forKey: .breakingNews) {
            self = .breakingNews(breakingNews)
        } else if let liveReport = try container.decodeIfPresent(LiveReportResponse.self, forKey: .liveReport) {
            self = .liveReport(liveReport)
        } else if let iframeCampaign = try container.decodeIfPresent(IframeCampaignResponse.self, forKey: .iframeCampaign) {
            self = .iframeCampaign(iframeCampaign)
        } else if let hotTopics = try container.decodeIfPresent(HotTopicsResponse.self, forKey: .hotTopics) {
            self = .hotTopics(hotTopics)
        } else if let articles = try container.decodeIfPresent([GenericArticle].self, forKey: .articles) {
            self = .articles(articles)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown section type"))
        }
    }
}
