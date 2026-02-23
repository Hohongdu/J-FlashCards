import ProjectDescription

let project = Project(
  name: "JFlashCards",
  options: .options(
    automaticSchemesOptions: .enabled(
      targetSchemesGrouping: .notGrouped,
      codeCoverageEnabled: false
    )
  ),
  targets: [
    Target(
      name: "JFlashCards",
      destinations: [.iPhone],
      product: .app,
      bundleId: "com.yoonjaego.jflashcards",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .extendingDefault(
        with: [
          "UILaunchScreen": ["UIColorName": "", "UIImageName": ""],
          "NSUserNotificationsUsageDescription": "오늘의 단어 알림을 보내기 위해 알림 권한이 필요해요."
        ]
      ),
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      entitlements: nil,
      dependencies: []
    )
  ]
)
