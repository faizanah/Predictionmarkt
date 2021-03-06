require 'spec_helper'
require 'pry'

describe 'The app itself' do

  def check_for_misspellings(filename)
    File.readlines(filename).each_with_index do |line,number|
      failing_lines << number + 1 if line =~ /PredictionMarket/
    end
  end

  def check_for_tab_characters(filename)
    failing_lines = []
    File.readlines(filename).each_with_index do |line,number|
      failing_lines << number + 1 if line =~ /\t/
    end

    unless failing_lines.empty?
      "#{filename} has tab characters on lines #{failing_lines.join(', ')}"
    end
  end

  def check_for_extra_spaces(filename)
    failing_lines = []
    File.readlines(filename).each_with_index do |line,number|
      next if line =~ /^\s+#.*\s+\n$/
      failing_lines << number + 1 if line =~ /\s+\n$/
    end

    unless failing_lines.empty?
      "#{filename} has spaces on the EOL on lines #{failing_lines.join(', ')}"
    end
  end

  RSpec::Matchers.define :be_well_formed do
    failure_message do |actual|
      actual.join("\n")
    end

    match do |actual|
      actual.empty?
    end
  end

  it "has no malformed whitespace" do
    error_messages = []
    Dir.chdir(File.expand_path("../..", __FILE__)) do
      `git ls-files`.split("\n").each do |filename|
        next if filename.include? 'app/assets/fonts'
        next if filename =~ /\.(?:json|lock|pdf|svg|png|swf|gif|jpg|ico|jpeg|reg|bundle\/config)$|jquery\.tooltip\.js$/
        next if filename =~ /fixtures/
        next if filename =~ /vendor/
        error_messages << check_for_tab_characters(filename)
        error_messages << check_for_extra_spaces(filename)
        error_messages << check_for_misspellings(filename)
      end
    end
    expect(error_messages.compact).to be_well_formed
  end
end
