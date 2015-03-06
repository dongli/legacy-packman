#!/usr/bin/env ruby

if not ENV.has_key? 'PACKMAN_ROOT'
  print "[Error]: #{File.expand_path(File.dirname(__FILE__))}/"+
    "setup.sh is not sourced!\n"
  exit
end

$LOAD_PATH << "#{ENV['PACKMAN_ROOT']}/framework"
require "package/package_spec"
require "package/package_dsl_helper"
require "package/package"
require "package/package_loader"

language = 'zh'
root = "../#{language}/packages"

PACKMAN::Package.all_package_names.each do |package_name|
  content = File.open("#{ENV['PACKMAN_ROOT']}/packages/#{package_name}.rb", 'r').read
  depends = content.scan /depends_on '(\w+)'/m
  # Write template package page.
  page_path = "#{root}/#{package_name}.html"
  if not File.exist? page_path
    File.open(page_path, 'w') do |page|
      page << <<-EOT
---
layout: default
title: #{package_name.capitalize}
category: zh
tags: package
---
<h1>简介</h1>
<p>
    填写简介。
</p>
<h1>依赖包</h1>
<p>
    <div class="depend-package-list">
      EOT
      if depends
        depends.each do |depend|
          page << "<a class=\"depend-package\" href=\"/packman/zh/packages/#{depend.first}.html\">#{depend.first.capitalize}</a>\n"
        end
      else
        page << '无\n'
      end
      page << <<-EOT
</div>
</p>
<h1>安装范例</h1>
<p>
    填写安装范例。
</p>
<h1>使用范例</h1>
<p>
    填写使用范例。
</p>
      EOT
    end
  end
end