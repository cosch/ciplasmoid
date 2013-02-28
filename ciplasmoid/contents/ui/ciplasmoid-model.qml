
import QtQuick 1.1
//http://gitorious.org/chakra/cinstall/blobs/14b7e72abb44b8e4d21715fcb1ac06ac0277c106/plasmoid/package/contents/ui/BundleModel.qml
ListModel {
    id: folderModel
    property string cinstallPath: plasmoid.userDataPath() + "/.cinstall/"

    function update(data) {
        folderModel.clear();
        var files = data["files.visible"];

        for (var i in files)
        {
            var fileName = files[i];
            if (fileName.indexOf(".cb") === -1)
                continue;

            folderModel.append({
                                   "fileName" : fileName,
                                   "filePath" : cinstallPath + "repo/" + fileName,
                                   "title" : fileName.substring(0, fileName.lastIndexOf("-")),
                                   "icon" : cinstallPath + "icons/" + fileName.replace(".cb", ".png")
                               });
        }
    }
}