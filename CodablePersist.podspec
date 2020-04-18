Pod::Spec.new do |s|
  s.name                      = "CodablePersist"
  s.version                   = "1.0.0"
  s.summary                   = "CodablePersist"
  s.homepage                  = "https://github.com/engali94/CodablePersist.git"
  s.license                   = { :type => "MIT", :file => "LICENSE" }
  s.author                    = { "Ali A, Hilal" => "ali94_200970@yahoo.com" }
  s.source                    = { :git => "https://github.com/engali94/CodablePersist.git.git", :tag => s.version.to_s }
  s.swift_version             = "5.1"
  s.ios.deployment_target     = "8.0"
  s.tvos.deployment_target    = "9.0"
  s.watchos.deployment_target = "2.0"
  s.osx.deployment_target     = "10.10"
  s.source_files              = "Sources/**/*"
  s.frameworks                = "Foundation"
end
