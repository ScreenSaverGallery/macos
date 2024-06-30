# Notarization

Notarize app after archive build (https://developer.apple.com/documentation/security/notarizing_your_app_before_distribution/customizing_the_notarization_workflow)

- Storing credentials in keychain 
`xcrun notarytool store-credentials "notarytool-password"
               --apple-id "<AppleID>"
               --team-id <DeveloperTeamID>
               --password <secret_2FA_password>`

- Notarize app
`$ xcrun notarytool submit PATH_TO_ZIPPED_FILE 
            --keychain-profile "notarytool-password" 
            --wait`
