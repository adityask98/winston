//
//  Badge.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import Foundation
import SwiftUI
import Defaults
import NukeUI

struct BadgeView: View, Equatable {
  static let authorStatsSpacing: Double = 2
  static func == (lhs: BadgeView, rhs: BadgeView) -> Bool {
    return lhs.cs == rhs.cs && lhs.avatarURL == rhs.avatarURL && lhs.saved == rhs.saved && lhs.avatarRequest?.url == rhs.avatarRequest?.url && lhs.theme == rhs.theme && lhs.commentsCount == rhs.commentsCount && lhs.votesCount == rhs.votesCount
  }
  
  var avatarRequest: ImageRequest?
  var saved = false
  var usernameColor: Color?
  var author: String
  var fullname: String? = nil
  var created: Double
  var avatarURL: String?
  var theme: BadgeTheme
  //  var extraInfo: [BadgeExtraInfo] = []
  var commentsCount: String?
  var votesCount: String?
  weak var routerProxy: RouterProxy?
  var cs: ColorScheme
  
  nonisolated func openUser() {
    routerProxy?.router.path.append(User(id: author, api: RedditAPI.shared))
  }
  
  var body: some View {
    let showAvatar = theme.avatar.visible
    let defaultIconColor = theme.statsText.color.cs(cs).color()
    HStack(spacing: theme.spacing) {
      
      if saved && !showAvatar {
        Image(systemName: "bookmark.fill")
          .fontSize(16)
          .foregroundColor(.green)
          .transition(.scale.combined(with: .opacity))
          .drawingGroup()
      }
      
      if showAvatar {
        AvatarRaw(saved: saved, avatarImgRequest: avatarRequest, userID: author, fullname: fullname, theme: theme.avatar)
          .equatable()
        //          .drawingGroup()
          .highPriorityGesture(TapGesture().onEnded(openUser))
      }
      
      VStack(alignment: .leading, spacing: BadgeView.authorStatsSpacing) {
        //
        Text(author).font(.system(size: theme.authorText.size, weight: theme.authorText.weight.t)).foregroundColor(author == "[deleted]" ? .red : usernameColor ?? theme.authorText.color.cs(cs).color())
          .onTapGesture(perform: openUser)
        ////
        HStack(alignment: .center, spacing: 6) {
          
          if let commentsCount = commentsCount {
            HStack(alignment: .center, spacing: 2) {
              Image(systemName: "message.fill")
              Text(commentsCount)
            }
          }
          
          if let votesCount = votesCount {
            HStack(alignment: .center, spacing: 2) {
              Image(systemName: "arrow.up")
              Text(votesCount)
            }
          }
          
          HStack(alignment: .center, spacing: 2) {
            Image(systemName: "hourglass.bottomhalf.filled")
            Text(timeSince(Int(created)))
          }
          
        }
        .foregroundStyle(defaultIconColor)
        .font(.system(size: theme.statsText.size, weight: theme.statsText.weight.t))
      }
      .drawingGroup()
    }
    .scaleEffect(1)
    .animation(showAvatar ? nil : spring.delay(0.4), value: saved)
  }
}

struct Badge: View {
  
  var cs: ColorScheme
  var routerProxy: RouterProxy?
  var showVotes = false
  var post: Post
  var usernameColor: Color?
  var avatarURL: String?
  var theme: BadgeTheme
  //  var extraInfo: [BadgeExtraInfo] = []
  
  
  var body: some View {
    if let data = post.data {
      //      let extraInfo = showVotes ? [BadgeExtraInfo(systemImage: "message.fill", text: "\(formatBigNumber(data.num_comments))"), BadgeExtraInfo(systemImage: "arrow.up", text: "\(formatBigNumber(data.ups))")] : [BadgeExtraInfo(systemImage: "message.fill", text: "\(formatBigNumber(data.num_comments))")]
      BadgeView(saved: data.saved, usernameColor: usernameColor, author: data.author, fullname: data.author_fullname, created: data.created, avatarURL: avatarURL, theme: theme, commentsCount: formatBigNumber(data.num_comments), votesCount: !showVotes ? nil : formatBigNumber(data.ups), routerProxy: routerProxy, cs: cs)
    }
  }
}

struct BadgeKit: Equatable {
  let numComments: Int
  let ups: Int
  let saved: Bool
  let author: String
  let authorFullname: String
  let created: Double
}

struct BadgeOpt: View, Equatable {
  static func == (lhs: BadgeOpt, rhs: BadgeOpt) -> Bool {
    return lhs.badgeKit == rhs.badgeKit && lhs.theme == rhs.theme && lhs.avatarRequest?.url == rhs.avatarRequest?.url && lhs.cs == rhs.cs
  }
  
  var avatarRequest: ImageRequest?
  let badgeKit: BadgeKit
  var cs: ColorScheme
  var routerProxy: RouterProxy?
  var showVotes = false
  var usernameColor: Color?
  var avatarURL: String?
  var theme: BadgeTheme
  //  var extraInfo: [BadgeExtraInfo] = []
  
  
  var body: some View {
    BadgeView(avatarRequest: avatarRequest ?? Caches.avatars.cache[badgeKit.authorFullname]?.data, saved: badgeKit.saved, usernameColor: usernameColor, author: badgeKit.author, fullname: badgeKit.authorFullname, created: badgeKit.created, avatarURL: avatarURL, theme: theme, commentsCount: formatBigNumber(badgeKit.numComments), votesCount: !showVotes ? nil : formatBigNumber(badgeKit.ups), routerProxy: routerProxy, cs: cs)
  }
}

struct BadgeComment: View, Equatable {
  static func == (lhs: BadgeComment, rhs: BadgeComment) -> Bool {
    return lhs.badgeKit == rhs.badgeKit && lhs.theme == rhs.theme && lhs.cs == rhs.cs
  }
  
  let badgeKit: BadgeKit
  var cs: ColorScheme
  var routerProxy: RouterProxy?
  var showVotes = false
  var usernameColor: Color?
  var avatarURL: String?
  var theme: BadgeTheme
  @ObservedObject private var avatarCache = Caches.avatars
  
  var body: some View {
    BadgeView(avatarRequest: avatarCache.cache[badgeKit.authorFullname]?.data, saved: badgeKit.saved, usernameColor: usernameColor, author: badgeKit.author, fullname: badgeKit.authorFullname, created: badgeKit.created, avatarURL: avatarURL, theme: theme, commentsCount: formatBigNumber(badgeKit.numComments), votesCount: !showVotes ? nil : formatBigNumber(badgeKit.ups), routerProxy: routerProxy, cs: cs)
  }
}

struct BadgeExtraInfo: Hashable, Equatable, Identifiable {
  static func == (lhs: BadgeExtraInfo, rhs: BadgeExtraInfo) -> Bool {
    lhs.id == rhs.id
  }
  var systemImage: String = ""
  var text: String
  //    var textColor: Color = Color.primary
  var iconColor: Color?
  var id: String {
    systemImage + text
  }
}
