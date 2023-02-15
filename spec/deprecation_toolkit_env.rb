# frozen_string_literal: true

if ENV.key?('RECORD_DEPRECATIONS')
  require 'deprecation_toolkit'
  require 'deprecation_toolkit/rspec'
  DeprecationToolkit::Configuration.test_runner = :rspec
  DeprecationToolkit::Configuration.deprecation_path = 'spec/deprecations'
  DeprecationToolkit::Configuration.behavior = DeprecationToolkit::Behaviors::Record
  Warning[:deprecated] = true
  DeprecationToolkit::Configuration.warnings_treated_as_deprecation = [//]
end
