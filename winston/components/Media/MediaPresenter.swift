//
//  MediaPresenter.swift
//  winston
//
//  Created by Igor Marcossi on 22/08/23.
//

import SwiftUI
import YouTubePlayerKit
import Defaults
import NukeUI

struct OnlyURL: View {
  static let height: Double = 22
  @Default(.postLinkTitleSize) var postLinkTitleSize
  var url: URL
  @Environment(\.openURL) private var openURL
  var body: some View {
    HStack {
      Image(systemName: "link")
      Text(url.absoluteString.replacingOccurrences(of: "https://", with: ""))
    }
    .padding(.horizontal, 6)
    .padding(.vertical, 2)
    .frame(maxHeight: OnlyURL.height)
    .background(Capsule(style: .continuous).fill(Color.accentColor.opacity(0.2)))
    .fontSize(15, .medium)
    .lineLimit(1)
    .foregroundColor(.white)
    .highPriorityGesture(TapGesture().onEnded {
      if let newURL = URL(string: url.absoluteString.replacingOccurrences(of: "https://reddit.com/", with: "winstonapp://")) {
        openURL(newURL)
      }
    })
  }
}

struct MediaPresenter: View, Equatable {
  static func == (lhs: MediaPresenter, rhs: MediaPresenter) -> Bool {
    lhs.compact == rhs.compact && lhs.contentWidth == rhs.contentWidth && lhs.badgeKit == rhs.badgeKit && lhs.cachedVideo == rhs.cachedVideo && lhs.cornerRadius == rhs.cornerRadius && lhs.media == rhs.media
  }
  
  @Binding var postDimensions: PostDimensions
  weak var controller: UIViewController?
  var cachedVideo: SharedVideo?
  var imgRequests: [ImageRequest]?
  let postTitle: String
  let badgeKit: BadgeKit
  let avatarImageRequest: ImageRequest?
  let markAsSeen: (() async -> ())?
  var cornerRadius: Double
  var blurPostLinkNSFW: Bool
  var showURLInstead = false
  let media: MediaExtractedType
  var over18 = false
  let compact: Bool
  let contentWidth: CGFloat
  weak var routerProxy: RouterProxy?
  
  var body: some View {
    switch media {
    case .imgs(let imgsExtracted):
      if !showURLInstead {
        if imgsExtracted.count > 0 && imgsExtracted[0].url.absoluteString.hasSuffix(".gif") {
          ImageMediaPost(postDimensions: $postDimensions, controller: controller, postTitle: postTitle, badgeKit: badgeKit, avatarImageRequest: avatarImageRequest, markAsSeen: markAsSeen, cornerRadius: cornerRadius, compact: compact, images: imgsExtracted, contentWidth: contentWidth)
            .nsfw(over18 && blurPostLinkNSFW)
        } else {
          ImageMediaPost(postDimensions: $postDimensions, controller: controller, postTitle: postTitle, badgeKit: badgeKit, avatarImageRequest: avatarImageRequest, markAsSeen: markAsSeen, cornerRadius: cornerRadius, compact: compact, images: imgsExtracted, contentWidth: contentWidth)
            .drawingGroup()
            .nsfw(over18 && blurPostLinkNSFW)
          
        }
      }
    case .video(let sharedVideo):
      if !showURLInstead {
        VideoPlayerPost(controller: controller, cachedVideo: sharedVideo, markAsSeen: markAsSeen, compact: compact, overrideWidth: contentWidth, url: sharedVideo.url)
          .nsfw(over18 && blurPostLinkNSFW)
      }
    case .yt(let ytMediaExtracted):
      if !showURLInstead {
        YTMediaPostPlayer(compact: compact, player: ytMediaExtracted.player, ytMediaExtracted: ytMediaExtracted, contentWidth: contentWidth)
      }
    case .link(let previewModel):
      if let previewURL = previewModel.previewURL {
        if !showURLInstead {
          PreviewLinkContent(compact: compact, viewModel: previewModel, url: previewURL)
        } else {
          OnlyURL(url: previewURL)
        }
      }
    case .post(let postExtractedEntity):
      if let postExtractedEntity = postExtractedEntity {
        if !showURLInstead {
          if compact, let sub = postExtractedEntity.subredditID, let postID = postExtractedEntity.postID {
            if let url = URL(string: "https://reddit.com/r/\(sub)/comments/\(postID)") {
              PreviewLink(url: url, compact: compact, previewModel: PreviewModel(url))
            }
          } else {
            RedditMediaPost(entity: .post(postExtractedEntity.entity))
          }
        } else if let sub = postExtractedEntity.subredditID, let postID = postExtractedEntity.postID, let url = URL(string: "https://reddit.com/r/\(sub)/comments/\(postID)") {
          OnlyURL(url: url)
        }
      }
    case .comment(let commentExtractedEntity):
      if let commentExtractedEntity = commentExtractedEntity {
        if !showURLInstead {
          if compact, let sub = commentExtractedEntity.subredditID, let postID = commentExtractedEntity.postID, let commentID = commentExtractedEntity.commentID {
            if let url = URL(string: "https://reddit.com/r/\(sub)/comments/\(postID)/comment/\(commentID)") {
              PreviewLink(url: url, compact: compact, previewModel: PreviewModel(url))
            }
          } else {
            RedditMediaPost(entity: .comment(commentExtractedEntity.entity))
          }
        } else if let sub = commentExtractedEntity.subredditID, let postID = commentExtractedEntity.postID, let commentID = commentExtractedEntity.commentID, let url = URL(string: "https://reddit.com/r/\(sub)/comments/\(postID)/comment/\(commentID)") {
          OnlyURL(url: url)
        }
      }
    case .subreddit(let subExtractedEntity):
      if let subExtractedEntity = subExtractedEntity {
        if !showURLInstead {
          if compact {
            if let url = URL(string: "https://reddit.com/r/\(subExtractedEntity.subredditID ?? "")") {
              PreviewLink(url: url, compact: compact, previewModel: PreviewModel(url))
            }
          } else {
            RedditMediaPost(entity: .subreddit(subExtractedEntity.entity))
          }
        } else if let url = URL(string: "https://reddit.com/r/\(subExtractedEntity.subredditID ?? "")") {
          OnlyURL(url: url)
        }
      }
    case .user(let userExtractedEntity):
      if let userExtractedEntity = userExtractedEntity {
        if !showURLInstead {
          if compact {
            if let url = URL(string: "https://reddit.com/u/\(userExtractedEntity.userID ?? "")") {
              PreviewLink(url: url, compact: compact, previewModel: PreviewModel(url))
            }
          } else {
            RedditMediaPost(entity: .user(userExtractedEntity.entity))
          }
        } else if let url = URL(string: "https://reddit.com/u/\(userExtractedEntity.userID ?? "")") {
          OnlyURL(url: url)
        }
      }
    default:
      EmptyView()
    }
  }
}
