# -*- coding: utf-8 -*-

module Everythingop
  module Dbutil
    class Everythingop
      def variable_init
        @group_criteria = {
          %s!git-sdk-64! => %w!C:\git-sdk-64
!,
      %s!stack_root! =>
%w!C:\stack_root
!,
      %s!Users\kominami\.emacs.d! =>
%w!C:\Users\kominami\.emacs.d
!,
      %s!Users\kominami\AppData! =>
%w!C:\Users\kominami\AppData
!,
      %s!Users\kominami\cur\ceylon! => 
%w!C:\Users\kominami\cur\ceylon
!,
      %s!Users\kominami\cur\gce! =>
%w!C:\Users\kominami\cur\gce
!,
      %s!Users\kominami\cur\golang! =>
%w!C:\Users\kominami\cur\golang
!,
      %s!Users\kominami\cur\nodejs! =>
%w!C:\Users\kominami\cur\nodejs
!,
      %s!Users\kominami\cur\perl! =>
%w!C:\Users\kominami\cur\perl
!,
      %s!Users\kominami\cur\pgp! =>
%w!C:\Users\kominami\cur\pgp
!,
      %s!Users\kominami\cur\ruby! =>
%w!C:\Users\kominami\cur\ruby
!,
      %s!Users\kominami\cur\tmp! =>
%w!C:\Users\kominami\cur\tmp
!,
      %s!Users\kominami\lib\emacs! =>
%w!C:\Users\kominami\lib\emacs
!,
      %s!Users\kominami\mingw-builds! =>
%w!C:\Users\kominami\mingw-builds
!,
      %s!Users\kominami\mingw-gcc-4.8.2! =>
%w!C:\Users\kominami\mingw-gcc-4.8.2
!,
      %s!Users\kominami\sshrc! =>
%w!C:\Users\kominami\sshrc
!,
      %s!Users\kominami\tmp! =>
%w!C:\Users\kominami\tmp
!,
      %s!Windows.old! =>
%w!C:\Windows.old
!,
      %s!work-af! =>
%w!C:\work-af
!,
      %s!ASP! =>
%w!V:\ASP
!,
      %s!ext2! =>
%w!V:\ext2
!,
      %s!BoxSync! =>
%w!X:\BoxSync
!,
      %s!dev! =>
%w!X:\dev
!,
      %s!ZX! =>
%w!X:\ZX
!,
      %s!FileHistory! =>
%w!Z:\FileHistory
!
        }
        @group_criteria_external = %q{C:\Program Files (x86)\Microsoft Visual Studio 14.0}

        @category_exclude_hs = {
          %s!FileHistory! =>
%w!Z:\FileHistory
!
        }
      
        @v_ext2_top_symbol = %s!ext2!

        @group_criteria_v_ext2 = {
          %s!_git!=>
%w!V:\ext2\_git
!,
        %s!BACKUP!=>
%w!V:\ext2\BACKUP!,
        %s!bitbucket-git-my-out!=>
%w!V:\ext2\bitbucket-git-my-out!,
        %s!bitbucket-git-my!=>
%w!V:\ext2\bitbucket-git-my!,
        %s!bitbucket-git!=>
%w!V:\ext2\bitbucket-git!,
        %s!dropbox-git-local!=>
%w!V:\ext2\dropbox-git-local!,
        %s!gist!=>
%w!V:\ext2\gist!,
        %s!git-appcelerator!=>
%w!V:\ext2\git-appcelerator!,
        %s!git-atom!=>
%w!V:\ext2\git-atom!,
        %s!git-box!=>
%w!V:\ext2\git-box
!,
        %s!git-clojure!=>
%w!V:\ext2\git-clojure
!,
        %s!git-closed!=>
%w!V:\ext2\git-closed
!,
        %s!git-dart!=>
%w!V:\ext2\git-dart
!,
        %s!git-docker!=>
%w!V:\ext2\git-docker
!,
        %s!git-evernote!=>
%w!V:\ext2\git-evernote
!,
        %s!git-example!=>
%w!V:\ext2\git-example
!,
        %s!git-facebook!=>
%w!V:\ext2\git-facebook
!,
        %s!git-fc2!=>
%w!V:\ext2\git-fc2
!,
        %s!git-for-windows!=>
%w!V:\ext2\git-for-windows
!,
        %s!git-git!=>
%w!V:\ext2\git-git
!,
        %s!git-github!=>
%w!V:\ext2\git-github
!,
        %s!git-groovy!=>
%w!V:\ext2\git-groovy
!,
        %s!git-grpc!=>
%w!V:\ext2\git-grpc
!,
        %s!git-iotkit!=>
%w!V:\ext2\git-iotkit
!,
        %s!git-mirror-v8!=>
%w!V:\ext2\git-mirror-v8
!,
        %s!git-misc!=>
%w!V:\ext2\git-misc
!,
        %s!git-mruby!=>
%w!V:\ext2\git-mruby
!,
        %s!git-nativescript!=>
%w!V:\ext2\git-nativescript
!,
        %s!git-nodejs!=>
%w!V:\ext2\git-nodejs
!,
        %s!git-onedrive!=>
%w!V:\ext2\git-onedrive
!,
        %s!git-osdn!=>
%w!V:\ext2\git-osdn
!,
        %s!git-osv!=>
%w!V:\ext2\git-osv
!,
        %s!git-parse!=>
%w!V:\ext2\git-parse
!,
        %s!git-pizzafactory!=>
%w!V:\ext2\git-pizzafactory
!,
        %s!git-qemu!=>
%w!V:\ext2\git-qemu
!,
        %s!git-redmine!=>
%w!V:\ext2\git-redmine
!,
        %s!git-ruby!=>
%w!V:\ext2\git-ruby
!,
        %s!git-rx!=>
%w!V:\ext2\git-rx
!,
        %s!git-savannah!=>
%w!V:\ext2\git-savannah
!,
        %s!git-sfj!=>
%w!V:\ext2\git-sfj
!,
        %s!git-sfn!=>
%w!V:\ext2\git-sfn
!,
        %s!git-simperium!=>
%w!V:\ext2\git-simperium
!,
        %s!git-smalruby!=>
%w!V:\ext2\git-smalruby
!,
        %s!git-sourceware!=>
%w!V:\ext2\git-sourceware
!,
        %s!git-svn-my!=>
%w!V:\ext2\git-svn-my
!,
        %s!git-svn-sfn!=>
%w!V:\ext2\git-svn-sfn
!,
        %s!git-svn-tecs!=>
%w!V:\ext2\git-svn-tecs
!,
        %s!git-svn-toppers!=>
%w!V:\ext2\git-svn-toppers
!,
        %s!git-swagger!=>
%w!V:\ext2\git-swagger
!,
        %s!git-swift!=>
%w!V:\ext2\git-swift
!,
        %s!git-toggl!=>
%w!V:\ext2\git-toggl
!,
        %s!git-trac!=>
%w!V:\ext2\git-trac
!,
        %s!git-ustream!=>
%w!V:\ext2\git-ustream
!,
        %s!git-webassembly!=>
%w!V:\ext2\git-webassembly
!,
        %s!git-wikimedia!=>
%w!V:\ext2\git-wikimedia
!,
        %s!git-workflowy!=>
%w!V:\ext2\git-workflowy
!,
        %s!git4!=>
%w!V:\ext2\git4
!,
        %s!git5!=>
%w!V:\ext2\git5
!,
        %s!git!=>
%w!V:\ext2\git
!,
        %s!github-my-1!=>
%w!V:\ext2\github-my-1
!,
        %s!github-my-2!=>
%w!V:\ext2\github-my-2
!,
        %s!github-my-out-succeed!=>
%w!V:\ext2\github-my-out-succeed
!,
        %s!github-my-out!=>
%w!V:\ext2\github-my-out
!,
        %s!gitolite-my!=>
%w!V:\ext2\gitolite-my
!,
        %s!no-git!=>
%w!V:\ext2\no-git
!,
        %s!tmp!=>
%w!V:\ext2\tmp
!
        }
      end
    end
  end
end
