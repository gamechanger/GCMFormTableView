namespace :debug do
  task :clean do |t|
    sh "xctool -workspace GCMFormTableView.xcworkspace -scheme GCMFormTableView -sdk iphonesimulator clean"
  end
  task :cleanbuild do |t|
    sh "xctool -workspace GCMFormTableView.xcworkspace -scheme GCMFormTableView -sdk iphonesimulator clean build"
  end
  task :build do |t|
    sh "xctool -workspace GCMFormTableView.xcworkspace -scheme GCMFormTableView -sdk iphonesimulator build"
  end
end

namespace :test do
  task :default do |t|
    sh "xctool -workspace GCMFormTableView.xcworkspace -scheme GCMFormTableView -sdk iphonesimulator -reporter plain test -freshInstall -freshSimulator"
  end

  task :ci => ["debug:cleanbuild", "test:default"]
end

task :analyze do
  sh "xctool -workspace GCMFormTableView.xcworkspace -scheme GCMFormTableView analyze"
end

task :test => "test:default"

