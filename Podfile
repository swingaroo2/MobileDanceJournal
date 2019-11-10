# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'MobileDanceJournal' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MobileDanceJournal
  pod 'Logging', '~> 1.1'
  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'
  pod 'Fabric'
  pod 'Crashlytics'
  
  # add pods for any other desired Firebase products
  # https://firebase.google.com/docs/ios/setup#available-pods

  target 'JiveJournalTests' do
    inherit! :search_paths
    pod 'Firebase/Analytics'
    pod 'Firebase/Performance'
  end

  target 'JiveJournalUITests' do
    inherit! :search_paths
    pod 'Firebase/Analytics'
    pod 'Firebase/Performance'
  end

end
