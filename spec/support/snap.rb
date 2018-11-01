require 'fileutils'

class SnapTaker
  attr_accessor :args, :page, :dir, :name

  def initialize(a)
    self.args = a
    self.page = a[:page]
    self.dir = a[:dir]
    self.name = a[:name]
  end

  def perform!
    with_each_screen_size do |screen_name|
      screenshot_driver.call(page.driver, snap_path(dir, "#{name}.#{screen_name}"))
    end
  end

  private

    # https://en.wikipedia.org/wiki/Display_resolution
    # https://en.wikipedia.org/wiki/Comparison_of_high-definition_smartphone_displays
    # https://www.w3schools.com/browsers/browsers_display.asp
    def with_each_screen_size
      screens = { wide: '1366x768', narrow: '827x1334' }
      screens.merge!(args[:screens]) if args[:screens]
      screens.each do |screen_name, screen_size|
        width, height = screen_size.split('x')
        Capybara.page.current_window.resize_to(width, height)
        yield(screen_name)
      end
    end

    def snap_path(dir, name, ext = 'png')
      full_dir = Rails.root.join("tmp/snaps/#{dir}")
      FileUtils.mkdir_p full_dir
      "#{full_dir}/#{name}.#{ext}"
    end

    def screenshot_driver
      raise "not supported driver #{Capybara.current_driver}" unless Capybara.current_driver == :chrome
      Capybara::Screenshot.registered_drivers.fetch(Capybara.current_driver)
    end
end

def snap(dir, name, args = {})
  snap_taker = SnapTaker.new(args.merge(dir: dir, name: name, page: page))
  snap_taker.perform!
end

def blog_snap(blog_id, name, height)
  args = { screens: { blog: "780x#{height}" } }
  snap("blog_posts/#{blog_id}", name, args)
  FileUtils.cp "tmp/snaps/blog_posts/#{blog_id}/#{name}.blog.png", "public/blog/#{blog_id}/#{name}.png"
end

def snap_email(dir, name)
  html_path = snap_path(dir, name, 'html')
  current_email.save_page(html_path)
  email_sess = Capybara::Session.new(:chrome)
  email_sess.visit("file://#{html_path}")
  email_sess.save_screenshot(snap_path(dir, name))
end

def snap_path(dir, name, ext = 'png')
  full_dir = Rails.root.join("tmp/snaps/#{dir}")
  FileUtils.mkdir_p full_dir
  "#{full_dir}/#{name}.#{ext}"
end
