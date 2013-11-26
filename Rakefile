
task :test do |t|
  sh "killall \"iPhone Simulator\" || true"
  sh "xctool -workspace GCMFormTableView.xcworkspace ONLY_ACTIVE_ARCH=NO ARCHS=i386 -scheme GCMFormTableView -sdk iphonesimulator clean build"
  sh "xctool -workspace GCMFormTableView.xcworkspace -scheme GCMFormTableView -sdk iphonesimulator test -freshInstall -freshSimulator"
  sh "xctool -workspace GCMFormTableView.xcworkspace -scheme GCMFormTableView analyze -failOnWarnings"
end
