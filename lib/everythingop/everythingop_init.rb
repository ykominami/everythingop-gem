# -*- coding: utf-8 -*-

module Everythingop
    class Everythingop
      def variable_init
        @group_criteria = {
          %s!/git-sdk-64! => %q!C:\git-sdk-64!,
      %s!/stack_root! =>
%q!C:\stack_root!,
      %s!/stack_root/1! =>
%q!C:\stack_root/1!,
      %s!/Users_kominami_.emacs.d! =>
%q!C:\Users\kominami\.emacs.d!,
      %s!/Users_kominami_AppData! =>
%q!C:\Users\kominami\AppData!,
      %s!/Users_kominami_cur_ceylon! => 
%q!C:\Users\kominami\cur\ceylon!,
      %s!/Users_kominami_cur_gce! =>
%q!C:\Users\kominami\cur\gce!,
      %s!/Users_kominami_cur_golang! =>
%q!C:\Users\kominami\cur\golang!,
      %s!/Users_kominami_cur_nodejs! =>
%q!C:\Users\kominami\cur\nodejs!,
      %s!/Users_kominami_cur_perl! =>
%q!C:\Users\kominami\cur\perl!,
      %s!/Users_kominami_cur_pgp! =>
%q!C:\Users\kominami\cur\pgp!,
      %s!/Users_kominami_cur_ruby! =>
%q!C:\Users\kominami\cur\ruby!,
      %s!/Users_kominami_cur_tmp! =>
%q!C:\Users\kominami\cur\tmp!,
      %s!/Users_kominami_lib_emacs! =>
%q!C:\Users\kominami\lib\emacs!,
      %s!/Users_kominami_mingw-builds! =>
%q!C:\Users\kominami\mingw-builds!,
      %s!/Users_kominami_mingw-gcc-4.8.2! =>
%q!C:\Users\kominami\mingw-gcc-4.8.2!,
      %s!/Users_kominami_sshrc! =>
%q!C:\Users\kominami\sshrc!,
      %s!/Users_kominami_tmp! =>
%q!C:\Users\kominami\tmp!,
      %s!/Windows.old! =>
%q!C:\Windows.old!,
      %s!/work-af! =>
%q!C:\work-af!,
      %s!/ASP! =>
%q!V:\ASP!,
      %s!/BoxSync! =>
%q!X:\BoxSync!,
      %s!/ZX! =>
%q!X:\ZX!,
      %s!/FileHistory! =>
%q!Z:\FileHistory!,
        }
        @group_criteria_external = %q{C:\Program Files (x86)\Microsoft Visual Studio 14.0}

        @category_exclude_hs = {
          %s!/FileHistory! =>
%q!Z:\FileHistory!
        }
      
        @v_ext2_git_top_symbol = %s!/ext2/git!

        @group_criteria_v_ext2 = {
          %s!/ext2/git/_git!=>
%q!V:\ext2\_git!,
        %s!/ext2/git/BACKUP!=>
%q!V:\ext2\BACKUP!,
        %s!/ext2/git/bitbucket-git-my-out!=>
%q!V:\ext2\bitbucket-git-my-out!,
        %s!/ext2/git/bitbucket-git-my!=>
%q!V:\ext2\bitbucket-git-my!,
        %s!/ext2/git/bitbucket-git!=>
%q!V:\ext2\bitbucket-git!,
        %s!/ext2/git/dropbox-git-local!=>
%q!V:\ext2\dropbox-git-local!,
        %s!/ext2/git/gist!=>
%q!V:\ext2\gist!,
        %s!/ext2/git/git-appcelerator!=>
%q!V:\ext2\git-appcelerator!,
        %s!/ext2/git/git-atom!=>
%q!V:\ext2\git-atom!,
        %s!/ext2/git/git-box!=>
%q!V:\ext2\git-box!,
        %s!/ext2/git/git-clojure!=>
%q!V:\ext2\git-clojure!,
        %s!/ext2/git/git-closed!=>
%q!V:\ext2\git-closed!,
        %s!/ext2/git/git-dart!=>
%q!V:\ext2\git-dart!,
        %s!/ext2/git/git-docker!=>
%q!V:\ext2\git-docker!,
        %s!/ext2/git/git-evernote!=>
%q!V:\ext2\git-evernote!,
        %s!/ext2/git/git-example!=>
%q!V:\ext2\git-example!,
        %s!/ext2/git/git-facebook!=>
%q!V:\ext2\git-faceboo!,
        %s!/ext2/git/git-fc2!=>
%q!V:\ext2\git-fc2!,
        %s!/ext2/git/git-for-windows!=>
%q!V:\ext2\/ext2/git-for-windows!,
        %s!/ext2/git/git-git!=>
%q!V:\ext2\git-git!,
        %s!/ext2/git/git-github!=>
%q!V:\ext2\git-github!,
        %s!/ext2/git/git-groovy!=>
%q!V:\ext2\git-groovy!,
        %s!/ext2/git/git-grpc!=>
%q!V:\ext2\git-grpc!,
        %s!/ext2/git/git-iotkit!=>
%q!V:\ext2\git-iotkit!,
        %s!/ext2/git/git-mirror-v8!=>
%q!V:\ext2\git-mirror-v8!,
        %s!/ext2/git/git-misc!=>
%q!V:\ext2\git-misc!,
        %s!/ext2/git/git-mruby!=>
%q!V:\ext2\git-mruby!,
        %s!/ext2/git/git-nativescript!=>
%q!V:\ext2\git-nativescript!,
        %s!/ext2/git/git-nodejs!=>
%q!V:\ext2\git-nodejs!,
        %s!/ext2/git/git-onedrive!=>
%q!V:\ext2\git-onedrive!,
        %s!/ext2/git/git-osdn!=>
%q!V:\ext2\git-osdn!,
        %s!/ext2/git/git-osv!=>
%q!V:\ext2\git-osv!,
        %s!/ext2/git/git-parse!=>
%q!V:\ext2\git-parse!,
        %s!/ext2/git/git-pizzafactory!=>
%q!V:\ext2\git-pizzafactory!,
        %s!/ext2/git/git-qemu!=>
%q!V:\ext2\git-qemu!,
        %s!/ext2/git/git-redmine!=>
%q!V:\ext2\git-redmine!,
        %s!/ext2/git/git-ruby!=>
%q!V:\ext2\git-ruby!,
        %s!/ext2/git/git-rx!=>
%q!V:\ext2\git-rx!,
        %s!/ext2/git/git-savannah!=>
%q!V:\ext2\git-savannah!,
        %s!/ext2/git/git-sfj!=>
%q!V:\ext2\git-sfj!,
        %s!/ext2/git/git-sfn!=>
%q!V:\ext2\git-sfn!,
        %s!/ext2/git/git-simperium!=>
%q!V:\ext2\git-simperium!,
        %s!/ext2/git/git-smalruby!=>
%q!V:\ext2\git-smalruby!,
        %s!/ext2/git/git-sourceware!=>
%q!V:\ext2\git-sourceware!,
        %s!/ext2/git/git-svn-my!=>
%q!V:\ext2\git-svn-my!,
        %s!/ext2/git/git-svn-sfn!=>
%q!V:\ext2\git-svn-sf!,
        %s!/ext2/git/git-svn-tecs!=>
%q!V:\ext2\git-svn-tecs!,
        %s!/ext2/git/git-svn-toppers!=>
%q!V:\ext2\git-svn-toppers!,
        %s!/ext2/git/git-swagger!=>
%q!V:\ext2\git-swagger!,
        %s!/ext2/git/git-swift!=>
%q!V:\ext2\git-swift!,
        %s!/ext2/git/git-toggl!=>
%q!V:\ext2\git-toggl!,
        %s!/ext2/git/git-trac!=>
%q!V:\ext2\git-trac!,
        %s!/ext2/git/git-ustream!=>
%q!V:\ext2\git-ustream!,
        %s!/ext2/git/git-webassembly!=>
%q!V:\ext2\git-webassembly!,
        %s!/ext2/git/git-wikimedia!=>
%q!V:\ext2\git-wikimedia!,
        %s!/ext2/git/git-workflowy!=>
%q!V:\ext2\git-workflowy!,
        %s!/ext2/git/git4!=>
%q!V:\ext2\git4!,
        %s!/ext2/git/git5!=>
%q!V:\ext2\git5!,
        %s!/ext2/git/git!=>
%q!V:\ext2\git!,
        %s!/ext2/git/github-my-1!=>
%q!V:\ext2\github-my-1!,
        %s!/ext2/git/github-my-2!=>
%q!V:\ext2\github-my-2!,
        %s!/ext2/git/github-my-out-succeed!=>
%q!V:\ext2\github-my-out-succeed!,
        %s!/ext2/git/github-my-out!=>
%q!V:\ext2\github-my-out!,
        %s!/ext2/git/gitolite-my!=>
%q!V:\ext2\gitolite-my!,
        %s!/ext2/git/no-git!=>
%q!V:\ext2\no-git!,
        %s!/ext2/git/tmp!=>
%q!V:\ext2\tmp!
        }
      end
    end
end
