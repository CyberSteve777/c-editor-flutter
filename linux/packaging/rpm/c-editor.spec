%global debug_package %{nil}

Name:           c-editor
Version:        @VERSION@
Release:        1%{?dist}
Summary:        Level Editor for Plants vs. Zombies 2 Chinese
License:        GPLv3
URL:            https://github.com/CyberSteve777/c-editor-flutter
BuildArch:      x86_64
AutoReqProv:    no
Requires:       gtk3
Requires:       liblzma

%description
C-Editor is a cross-platform level editor for Plants vs. Zombies 2 Chinese.

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/opt/c-editor
cp -a /github/workspace/build/linux/x64/release/bundle/. %{buildroot}/opt/c-editor/
mkdir -p %{buildroot}%{_bindir}
ln -sf /opt/c-editor/C-Editor %{buildroot}%{_bindir}/c-editor
mkdir -p %{buildroot}%{_datadir}/applications
install -m 644 /github/workspace/linux/packaging/c_editor.desktop %{buildroot}%{_datadir}/applications/c-editor.desktop
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/256x256/apps
install -m 644 /github/workspace/assets/meta/icon.png %{buildroot}%{_datadir}/icons/hicolor/256x256/apps/c_editor.png

%files
/opt/c-editor
%{_bindir}/c-editor
%{_datadir}/applications/c-editor.desktop
%{_datadir}/icons/hicolor/256x256/apps/c_editor.png
