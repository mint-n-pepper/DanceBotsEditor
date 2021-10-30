import os
import uuid
import xml.etree.ElementTree as ET

_UPGRADECODE = "23AE508C-B901-4871-8680-08E21EF226C0"
_GENERATEUUIDSTR = "GENERATE_NEW_UUID"

_productAttributes = {
    "Id":_GENERATEUUIDSTR,
    "UpgradeCode":_UPGRADECODE,
    "Version":"1.2.0",
    "Language": "1033",
    "Name":"DanceBots Editor",
    "Manufacturer":"Mint and Pepper"
}

_packageAttributes = {
    "InstallerVersion":"300",
    "Compressed":"yes"
}

_mediaAttributes = {
    "Id":"1",
    "Cabinet":"dancebotsEditor.cab",
    "EmbedCab":"yes"
}

_iconAttributes = {
    "Id":"icon.ico",
    "SourceFile":"applogo.ico"
}

_uninstallIconAttributes = {
    "Id":"ARPPRODUCTICON",
    "Value":"icon.ico"
}

_majorUpgradeAttributes = {
    "Schedule":"afterInstallInitialize",
    "DowngradeErrorMessage":"A later version of the Dancebots Editor is already installed. Setup will now exit."
}

_shortCutAttributes = {
    "Id":"ApplicationStartMenuShortcut",
    "Name": "DanceBots Editor",
    "Description":"The DanceBots Choreography Editor",
    "Target":"[#dancebotsEditor.exe]",
    "WorkingDirectory":"APPLICATIONROOTDIRECTORY"
}

_shortCutRemoveFolderAttributes = {
    "Id":"ApplicationProgramsFolder",
    "On":"uninstall"
}

_shortCutRegistryAttributes = {
    "Root":"HKCU",
    "Key":"Software\MintPepper\Dancebots",
    "Name":"installed",
    "Type":"integer",
    "Value":"1",
    "KeyPath":"yes"
}


def _indent(elem, level=0):
    i = "\n" + level*"  "
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "  "
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            _indent(elem, level+1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i

def _setAttributesWithUUIDCheck(element, attributes):
    for k,v in attributes.items():
        if v == _GENERATEUUIDSTR:
            v = str(uuid.uuid4()).upper()
        element.set(k, v)

def _createFolderElement(parentElement: ET.Element, idStr: str, nameStr: str = "") -> ET.Element:
    newDirElement = ET.SubElement(parentElement, "Directory")
    newDirElement.set("Id", idStr)
    if nameStr:
        newDirElement.set("Name", nameStr)
    return newDirElement

def _createDirectoryRef(parentElement: ET.Element, idStr: str) -> ET.Element:
    newDirElement = ET.SubElement(parentElement, "DirectoryRef")
    newDirElement.set("Id", idStr)
    return newDirElement

def _createComponent(dirRefParent: ET.Element, componentsRoot: ET.Element, idStr:str) -> ET.Element:
    component = ET.SubElement(dirRefParent, "Component")
    component.set("Id", idStr)
    component.set("Guid", str(uuid.uuid4()).upper())
    # create install component ref:
    cref = ET.SubElement(componentsRoot, "ComponentRef")
    cref.set("Id", idStr)
    return component

def _addFile(component: ET.Element, srcStr: str, idStr:str) -> ET.Element:
    file = ET.SubElement(component, "File")
    file.set("Id", idStr)
    file.set("Source", srcStr)
    file.set("KeyPath", "yes")
    if srcStr[-3:] == "exe":
        file.set("Checksum", "yes")

def _addFiles(rootDir: str, rootFolderElement: ET.Element, productElement: ET.Element, componentsRoot, itemNum) -> int:
    items = os.listdir(rootDir)
    rootFolderId = rootFolderElement.get("Id")
    curDirRef = None  # lazy add only if a file is present
    for item in items:
        if item == "dancebotsEditor.exe":
            itemID = "dancebotsEditor.exe"
        else:
            itemID = f"ITEM_{itemNum:03d}"
            itemNum += 1
        itemPath = os.path.join(rootDir, item)
        if os.path.isdir(itemPath):
            folderItem = _createFolderElement(rootFolderElement, itemID, str(item))
            itemNum = _addFiles(os.path.join(rootDir, item), folderItem, productElement, componentsRoot, itemNum)
        elif os.path.isfile(itemPath):
            if curDirRef is None:
                curDirRef = _createDirectoryRef(productElement, rootFolderId)
            component = _createComponent(curDirRef, componentsRoot, itemID)
            _addFile(component, str(itemPath), itemID)
    return itemNum

def run():
    # setup header
    root = ET.Element('Wix')
    root.set("xmlns", "http://schemas.microsoft.com/wix/2006/wi")
    product = ET.SubElement(root, "Product")
    _setAttributesWithUUIDCheck(product, _productAttributes)
    package = ET.SubElement(product, 'Package')
    _setAttributesWithUUIDCheck(package, _packageAttributes)
    media = ET.SubElement(product, 'Media')
    _setAttributesWithUUIDCheck(media, _mediaAttributes)
    icon = ET.SubElement(product, 'Icon')
    _setAttributesWithUUIDCheck(icon, _iconAttributes)
    uninstallIcon = ET.SubElement(product, 'Property')
    _setAttributesWithUUIDCheck(uninstallIcon, _uninstallIconAttributes)
    majorUpgrade = ET.SubElement(product, 'MajorUpgrade')
    _setAttributesWithUUIDCheck(majorUpgrade, _majorUpgradeAttributes)

    # setup UX:
    installDirProperty = ET.SubElement(product, 'Property')
    installDirProperty.set("Id", "WIXUI_INSTALLDIR")
    installDirProperty.set("Value", "APPLICATIONROOTDIRECTORY")
    uiRef = ET.SubElement(product, 'UIRef')
    uiRef.set("Id", "WixUI_InstallDir")
    uiLicense = ET.SubElement(product, 'WixVariable')
    uiLicense.set("Id", "WixUILicenseRtf")
    uiLicense.set("Value", "LICENSE.rtf")

    # setup program root folder:
    sourceDir = _createFolderElement(product, "TARGETDIR", "SourceDir")
    programFiles = _createFolderElement(sourceDir, "ProgramFilesFolder")
    programRoot = _createFolderElement(programFiles, "APPLICATIONROOTDIRECTORY", "Dancebots")

    # add program menu folder:
    programMenu = _createFolderElement(sourceDir, "ProgramMenuFolder")
    _createFolderElement(programMenu, "ApplicationProgramsFolder", "Dancebots")

    # add components root:
    componentsRoot = ET.SubElement(product, 'Feature')
    componentsRoot.set("Id", "DancebotsEditor")
    componentsRoot.set("Title", "DancebotsEditor")
    componentsRoot.set("Level", "1")

    # add application shortcut directory ref:
    appFolderRef = _createDirectoryRef(product, "ApplicationProgramsFolder")
    appFolderComponent = _createComponent(appFolderRef, componentsRoot, "ApplicationShortcut")
    shortCut = ET.SubElement(appFolderComponent, "Shortcut")
    _setAttributesWithUUIDCheck(shortCut, _shortCutAttributes)
    shortRF = ET.SubElement(appFolderComponent, "RemoveFolder")
    _setAttributesWithUUIDCheck(shortRF, _shortCutRemoveFolderAttributes)
    shortCutReg = ET.SubElement(appFolderComponent, "RegistryValue")
    _setAttributesWithUUIDCheck(shortCutReg, _shortCutRegistryAttributes)

    # recursive directory structure setup:
    _addFiles(".\\Release", programRoot, product, componentsRoot, 42)

    # finalize
    tree = ET.ElementTree(root)
    _indent(root)
    tree.write("dancebots.wxs", encoding="UTF-8", xml_declaration=True)

if __name__ == "__main__":
    run()
