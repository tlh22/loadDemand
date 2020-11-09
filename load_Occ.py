# -*- coding: utf-8 -*-
"""
/***************************************************************************
 loadOcc
                                 A QGIS plugin
 Loads data from occupancy survey
                              -------------------
        begin                : 2018-09-14
        git sha              : $Format:%H$
        copyright            : (C) 2018 by MHTC
        email                : th@mhtc.co.uk
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
"""
#from PyQt4.QtCore import QSettings, QTranslator, qVersion, QCoreApplication
#from PyQt4.QtGui import QAction, QIcon

#from PyQt4.QtGui import *


from qgis.PyQt.QtWidgets import (
    QMessageBox,
    QAction,
    QDialogButtonBox,
    QLabel,
    QDockWidget
)

from qgis.PyQt.QtGui import (
    QIcon,
    QPixmap
)

from qgis.PyQt.QtCore import (
    QObject, QTimer, pyqtSignal,
    QTranslator,
    QSettings,
    QCoreApplication,
    qVersion
)

from TOMs.core.TOMsMessageLog import TOMsMessageLog
from qgis.core import (
    Qgis,
    QgsMessageLog,
    QgsProject,
    QgsApplication, QgsExpression, QgsFeatureRequest, QgsMapLayer
)

from qgis.gui import (QgsMapCanvas)

# Initialize Qt resources from file resources.py
from .resources import *
# Import the code for the dialog
from loadOcc.load_Occ_dialog import loadOccDialog
import os.path
#from qgis.gui import *
#from qgis.core import *

# See following for using QgsMapLayerComboBox - https://stackoverflow.com/questions/44079328/python-load-module-in-parent-to-prevent-overwrite-problems

class loadOcc:
    """QGIS Plugin Implementation."""

    def __init__(self, iface):
        """Constructor.

        :param iface: An interface instance that will be passed to this class
            which provides the hook by which you can manipulate the QGIS
            application at run time.
        :type iface: QgsInterface
        """
        # Save reference to the QGIS interface
        self.iface = iface
        # initialize plugin directory
        self.plugin_dir = os.path.dirname(__file__)
        # initialize locale
        locale = QSettings().value('locale/userLocale')[0:2]
        locale_path = os.path.join(
            self.plugin_dir,
            'i18n',
            'loadOcc_{}.qm'.format(locale))

        if os.path.exists(locale_path):
            self.translator = QTranslator()
            self.translator.load(locale_path)

            if qVersion() > '4.3.3':
                QCoreApplication.installTranslator(self.translator)


        # Declare instance attributes
        self.actions = []
        self.menu = self.tr(u'&loadOccupancyDetails')
        # TODO: We are going to let the user set this up in a future iteration
        self.toolbar = self.iface.addToolBar(u'loadOcc')
        self.toolbar.setObjectName(u'loadOcc')

        #self.canvas = QgsMapCanvas()
        #self.root = QgsProject.instance().layerTreeRoot()

    # noinspection PyMethodMayBeStatic
    def tr(self, message):
        """Get the translation for a string using Qt translation API.

        We implement this ourselves since we do not inherit QObject.

        :param message: String for translation.
        :type message: str, QString

        :returns: Translated version of message.
        :rtype: QString
        """
        # noinspection PyTypeChecker,PyArgumentList,PyCallByClass
        return QCoreApplication.translate('loadOcc', message)


    def add_action(
        self,
        icon_path,
        text,
        callback,
        enabled_flag=True,
        add_to_menu=True,
        add_to_toolbar=True,
        status_tip=None,
        whats_this=None,
        parent=None):
        """Add a toolbar icon to the toolbar.

        :param icon_path: Path to the icon for this action. Can be a resource
            path (e.g. ':/plugins/foo/bar.png') or a normal file system path.
        :type icon_path: str

        :param text: Text that should be shown in menu items for this action.
        :type text: str

        :param callback: Function to be called when the action is triggered.
        :type callback: function

        :param enabled_flag: A flag indicating if the action should be enabled
            by default. Defaults to True.
        :type enabled_flag: bool

        :param add_to_menu: Flag indicating whether the action should also
            be added to the menu. Defaults to True.
        :type add_to_menu: bool

        :param add_to_toolbar: Flag indicating whether the action should also
            be added to the toolbar. Defaults to True.
        :type add_to_toolbar: bool

        :param status_tip: Optional text to show in a popup when mouse pointer
            hovers over the action.
        :type status_tip: str

        :param parent: Parent widget for the new action. Defaults None.
        :type parent: QWidget

        :param whats_this: Optional text to show in the status bar when the
            mouse pointer hovers over the action.

        :returns: The action that was created. Note that the action is also
            added to self.actions list.
        :rtype: QAction
        """

        # Create the dialog (after translation) and keep reference
        self.dlg = loadOccDialog()

        icon = QIcon(icon_path)
        action = QAction(icon, text, parent)
        action.triggered.connect(callback)
        action.setEnabled(enabled_flag)

        if status_tip is not None:
            action.setStatusTip(status_tip)

        if whats_this is not None:
            action.setWhatsThis(whats_this)

        if add_to_toolbar:
            self.toolbar.addAction(action)

        if add_to_menu:
            self.iface.addPluginToMenu(
                self.menu,
                action)

        self.actions.append(action)

        return action

    def initGui(self):
        """Create the menu entries and toolbar icons inside the QGIS GUI."""

        icon_path = ':/plugins/loadOcc/icon.png'
        self.add_action(
            icon_path,
            text=self.tr(u'Load occupancy data'),
            callback=self.run,
            parent=self.iface.mainWindow())

        # Need to set up signals for layerChanged


    def unload(self):
        """Removes the plugin menu item and icon from QGIS GUI."""
        for action in self.actions:
            self.iface.removePluginMenu(
                self.tr(u'&loadOccupancyDetails'),
                action)
            self.iface.removeToolBarIcon(action)
        # remove the toolbar
        del self.toolbar


    def run(self):
        """Run method that performs all the real work"""
        # show the dialog
        self.dlg.show()
        # Run the dialog event loop
        result = self.dlg.exec_()
        layers = QgsProject.instance().mapLayers().values()

        """
        self.updateList = ["Done", "SurveyDate",
                           "ncars", "nlgvs", "nmcls", "nogvs", "ntaxis", "nminib", "nbuses", "nbikes", "nspaces", "nnotes",
                           "sref", "sbays", "sreason", "scars", "slgvs", "smcls", "sogvs", "staxis", "sbuses", "sogvs2", "sminib", "snotes",
                           "dcars", "dlgvs", "dmcls", "dogvs", "dtaxis", "dbuses", "dogvs2", "dminib",
                           "Photos_01", "Photos_02", "Photos_03"]
        """

        self.updateList = ["Done", "SurveyDate", "VRM_01",
                           "VRM_02", "VRM_03", "VRM_04", "VRM_05", "VRM_06", "VRM_07", "VRM_08",
                           "VRM_09", "VRM_10", "VRM_11", "VRM_12", "VRM_13", "VRM_14", "VRM_15",
                           "VRM_16", "VRM_17", "VRM_18", "VRM_19", "VRM_20", "VRM_21", "VRM_22",
                           "VRM_23", "VRM_24", "VRM_25", "VRM_26", "VRM_27", "VRM_28", "VRM_29",
                           "VRM_30", "VRM_31", "VRM_32", "VRM_33", "VRM_34", "VRM_35", "VRM_36",
                           "VRM_37", "VRM_38", "VRM_39", "VRM_40", "VRM_41", "VRM_42", "VRM_43",
                           "VRM_44", "VRM_45", "VRM_46", "VRM_47", "VRM_48", "VRM_49", "VRM_50",
                           "VehicleTypeID_01", "VehicleTypeID_02", "VehicleTypeID_03", "VehicleTypeID_04", "VehicleTypeID_05",
                           "VehicleTypeID_06", "VehicleTypeID_07", "VehicleTypeID_08", "VehicleTypeID_09", "VehicleTypeID_10",
                           "VehicleTypeID_11", "VehicleTypeID_12", "VehicleTypeID_13", "VehicleTypeID_14", "VehicleTypeID_15",
                           "VehicleTypeID_16", "VehicleTypeID_17", "VehicleTypeID_18", "VehicleTypeID_19", "VehicleTypeID_20",
                           "VehicleTypeID_21", "VehicleTypeID_22", "VehicleTypeID_23", "VehicleTypeID_24", "VehicleTypeID_25",
                           "VehicleTypeID_26", "VehicleTypeID_27", "VehicleTypeID_28", "VehicleTypeID_29", "VehicleTypeID_30",
                           "VehicleTypeID_31", "VehicleTypeID_32", "VehicleTypeID_33", "VehicleTypeID_34", "VehicleTypeID_35",
                           "VehicleTypeID_36", "VehicleTypeID_37", "VehicleTypeID_38", "VehicleTypeID_39", "VehicleTypeID_40",
                           "VehicleTypeID_41", "VehicleTypeID_42", "VehicleTypeID_43", "VehicleTypeID_44", "VehicleTypeID_45",
                           "VehicleTypeID_46", "VehicleTypeID_47", "VehicleTypeID_48", "VehicleTypeID_49", "VehicleTypeID_50",

                           "Notes_01", "Notes_02", "Notes_03", "Notes_04", "Notes_05", "Notes_06",
                           "Notes_07", "Notes_08", "Notes_09", "Notes_10", "Notes_11", "Notes_12",
                           "Notes_13", "Notes_14", "Notes_15", "Notes_16", "Notes_17", "Notes_18",
                           "Notes_19", "Notes_20", "Notes_21", "Notes_22", "Notes_23", "Notes_24",
                           "Notes_25", "Notes_26", "Notes_27", "Notes_28", "Notes_29", "Notes_30",
                           "Notes_31", "Notes_32", "Notes_33", "Notes_34", "Notes_35", "Notes_36",
                           "Notes_37", "Notes_38", "Notes_39", "Notes_40", "Notes_41", "Notes_42",
                           "Notes_43", "Notes_44", "Notes_45", "Notes_46", "Notes_47", "Notes_48",
                           "Notes_49", "Notes_50",

                           "PermitType_01", "PermitType_02", "PermitType_03",
                           "PermitType_04", "PermitType_05", "PermitType_06", "PermitType_07", "PermitType_08",
                           "PermitType_09", "PermitType_10", "PermitType_11", "PermitType_12", "PermitType_13",
                           "PermitType_14", "PermitType_15", "PermitType_16", "PermitType_17", "PermitType_18",
                           "PermitType_19", "PermitType_20", "PermitType_21", "PermitType_22", "PermitType_23",
                           "PermitType_24", "PermitType_25", "PermitType_26", "PermitType_27", "PermitType_28",
                           "PermitType_29", "PermitType_30", "PermitType_31", "PermitType_32", "PermitType_33",
                           "PermitType_34", "PermitType_35", "PermitType_36", "PermitType_37", "PermitType_38",
                           "PermitType_39", "PermitType_40", "PermitType_41", "PermitType_42", "PermitType_43",
                           "PermitType_44", "PermitType_45", "PermitType_46", "PermitType_47", "PermitType_48",
                           "PermitType_49", "PermitType_50",
                           
                           "RestrictionTypeID_01", "RestrictionTypeID_02", "RestrictionTypeID_03",
                           "RestrictionTypeID_04", "RestrictionTypeID_05", "RestrictionTypeID_06", "RestrictionTypeID_07", "RestrictionTypeID_08",
                           "RestrictionTypeID_09", "RestrictionTypeID_10", "RestrictionTypeID_11", "RestrictionTypeID_12", "RestrictionTypeID_13",
                           "RestrictionTypeID_14", "RestrictionTypeID_15", "RestrictionTypeID_16", "RestrictionTypeID_17", "RestrictionTypeID_18",
                           "RestrictionTypeID_19", "RestrictionTypeID_20", "RestrictionTypeID_21", "RestrictionTypeID_22", "RestrictionTypeID_23",
                           "RestrictionTypeID_24", "RestrictionTypeID_25", "RestrictionTypeID_26", "RestrictionTypeID_27", "RestrictionTypeID_28",
                           "RestrictionTypeID_29", "RestrictionTypeID_30", "RestrictionTypeID_31", "RestrictionTypeID_32", "RestrictionTypeID_33",
                           "RestrictionTypeID_34", "RestrictionTypeID_35", "RestrictionTypeID_36", "RestrictionTypeID_37", "RestrictionTypeID_38",
                           "RestrictionTypeID_39", "RestrictionTypeID_40", "RestrictionTypeID_41", "RestrictionTypeID_42", "RestrictionTypeID_43",
                           "RestrictionTypeID_44", "RestrictionTypeID_45", "RestrictionTypeID_46", "RestrictionTypeID_47", "RestrictionTypeID_48",
                           "RestrictionTypeID_49", "RestrictionTypeID_50",

                           "SuspensionReference", "SuspensionReason", "SuspensionLength", "NrBaysSuspended",
                           "SuspensionNotes",
                           "Photos_01", "Photos_02", "Photos_03"

                           ]

        surveyIDField = 'SurveyID'
        # See if OK was pressed
        if result:
            # Do something useful here - delete the line containing pass and
            # substitute with your code.
            # pass

            self.masterLayer = self.dlg.cb_layerMaster.currentLayer()

            QMessageBox.information(self.iface.mainWindow(),"hello world","%s has %d features." %(self.masterLayer.name(),self.masterLayer.featureCount()))

            self.masterLayer.startEditing()

            QgsMessageLog.logMessage("In loadOcc. masterLayer: " + str(self.masterLayer.name()),
                                     tag="TOMs panel")

            #VRMfeatures = []
            masterFields = self.masterLayer.fields()

            self.idxSurveyTime = self.masterLayer.fields().indexFromName("SurveyTime")
            self.idxSurveyID = self.masterLayer.fields().indexFromName(surveyIDField)

            try:
                firstMaster = next(row for row in self.masterLayer.getFeatures())
            except StopIteration:
                QMessageBox.information(self.iface.mainWindow(), "Checking time periods",  "No rows in " + self.masterLayer.name())
                return

            currSurveyID = firstMaster[self.idxSurveyID]
            currSurveyTime = firstMaster[self.idxSurveyTime]

            QgsMessageLog.logMessage("In loadOcc. currSurveyTime: " + str(currSurveyTime),
                                     tag="TOMs panel")

            # For each layer in the project file

            for layer in layers:

                if self.isCurrOcclayer(layer, currSurveyID, surveyIDField):

                    # Select the rows (GeometryIDs) where Done = “true”
                    query = "\"Done\" = 'true'"
                    query = "\"Done\""
                    expr = QgsExpression(query)
                    #selection = layer.getFeatures(QgsFeatureRequest(expr))

                    #layer.setSelectedFeatures([k.id() for k in selection])
                    #QMessageBox.information(self.iface.mainWindow(), "In loadOcc",  "count within %s: %d" %(layer.name(), layer.selectedFeatureCount()))

                    # Now copy the required rows/attributes into the MasterLayer

                    layerFeatureCount = 0
                    for feature in layer.getFeatures(QgsFeatureRequest(expr)):

                        status = self.copyAttributes(feature)
                        if status:
                            layerFeatureCount = layerFeatureCount + 1

                    parent = QgsProject.instance().layerTreeRoot().findLayer(layer.id()).parent().name()
                    QgsMessageLog.logMessage(
                        "In loadOcc. count of records added within " + parent + ":" + layer.name() + ": " + str(layerFeatureCount),
                        tag="TOMs panel")

            QgsMessageLog.logMessage("In loadOcc. Now committing ... ",
                                     tag="TOMs panel")
            self.masterLayer.commitChanges()

    def isCurrOcclayer(self, layer, currSurveyID, surveyIDField):

        # checks to see if this is a layer is for the correct survey period

        if layer != self.masterLayer:

            if layer.type() == QgsMapLayer.VectorLayer:
                QgsMessageLog.logMessage("In isCurrOcclayer. considering layer: " + str(layer.name()),
                                         tag="TOMs panel")

                for field in layer.fields():
                    if field.name() == "SurveyID":
                        try:
                            firstRow = next(row for row in layer.getFeatures())
                        except StopIteration:
                            QgsMessageLog.logMessage(
                                "In isCurrOcclayer. Error checking survey time: " + str(layer.name()),
                                tag="TOMs panel")
                            return False

                        QgsMessageLog.logMessage("In isCurrOcclayer. layer: {}  has surveyID {}".format(layer.name(), str(firstRow.attribute("SurveyID"))),
                            tag="TOMs panel")

                        if currSurveyID == firstRow.attribute(surveyIDField):
                            QgsMessageLog.logMessage("In isCurrOcclayer. layer: " + str(layer.name() + " is for processing ..."),
                                                     tag="TOMs panel")
                            return True

        return False

    def copyAttributes(self, feature):

        # copies relevant details into the master Layer

        status = True
        currAttribs = feature.attributes()
        currGeometryID = feature.attribute("gid")

        QgsMessageLog.logMessage("In copyAttributes. GeometryID: " + str(currGeometryID),
                                 tag="TOMs panel")
        # Now find the row for this GeometryID in masterLayer
        query = ('"gid" = \'{}\' AND ("Done" = \'false\' OR "Done" IS NULL)').format(currGeometryID)
        expr = QgsExpression(query)
        selection = self.masterLayer.getFeatures(QgsFeatureRequest(expr))

        #masterIterator = (row for row in selection)
        try:
            masterRow = next(row for row in selection)
            rowFound = True
        except StopIteration:

            """QgsMessageLog.logMessage("In copyAttributes. Error retrieving GeometryID: " + str(currGeometryID),
                                     tag="TOMs panel")"""
            rowFound = False
            status = False

        if rowFound == True:

            for field in self.updateList:

                idxCurrFieldValue = feature.fields().indexFromName(field)
                idxMasterFieldValue = masterRow.fields().indexFromName(field)

                try:
                    updStatus = masterRow.setAttribute(idxMasterFieldValue, feature[idxCurrFieldValue])
                except IndexError:
                    #updStatus = self.masterLayer.changeAttributeValue(masterRow.id(), masterRow.fieldNameIndex(field), feature.attribute(idxCurrFieldValue))

                    QgsMessageLog.logMessage("In copyAttributes: Index error occurred updating field " + field + " in " + str(currGeometryID), tag="TOMs panel")
                except KeyError:
                    #updStatus = self.masterLayer.changeAttributeValue(masterRow.id(), masterRow.fieldNameIndex(field), feature.attribute(idxCurrFieldValue))

                    QgsMessageLog.logMessage("In copyAttributes. Key error occurred updating field " + field + " in " + str(currGeometryID), tag="TOMs panel")

            status = self.masterLayer.updateFeature(masterRow)

            if status == False:
                QMessageBox.information(self.iface.mainWindow(), "In copyAttributes",  "Error occurred updating record " + currGeometryID)

        else:
            QgsMessageLog.logMessage("In copyAttributes: duplicate details for " + str(currGeometryID), tag="TOMs panel")
            return False
        #selection.close()

        return status



