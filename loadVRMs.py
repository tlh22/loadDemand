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

from qgis.PyQt.QtCore import (
    QObject,
    QTimer,
    pyqtSignal,
    QSettings, QTranslator, qVersion, QCoreApplication, Qt, QModelIndex,
)

from qgis.PyQt.QtGui import (
    QIcon, QStandardItemModel, QStandardItem,
    QPixmap
                             )
from qgis.PyQt.QtWidgets import (
    QAction,
    QWidget,
    QMessageBox,
    QDialog,
    QVBoxLayout, QCheckBox, QListView, QAbstractItemView, QFormLayout, QDialogButtonBox, QLabel, QGroupBox,
    QDockWidget, QFileDialog
)

from qgis.PyQt.QtSql import (
    QSqlDatabase, QSqlQuery, QSqlQueryModel, QSqlRelation, QSqlRelationalTableModel, QSqlRelationalDelegate
)

from TOMs.core.TOMsMessageLog import TOMsMessageLog

from qgis.core import (
    Qgis,
    QgsMessageLog,
    QgsProject,
    QgsApplication, QgsExpression, QgsFeatureRequest, QgsMapLayer,
    QgsExpressionContextUtils
)

from qgis.gui import (QgsMapCanvas)

# Initialize Qt resources from file resources.py
from .resources import *
# Import the code for the dialog
from loadOcc.load_Occ_dialog import loadOccDialog
from TOMsExport.checkableMapLayerList import checkableMapLayerListCtrl, checkableMapLayerList

import os
import os.path
#from qgis.gui import *
#from qgis.core import *

# See following for using QgsMapLayerComboBox - https://stackoverflow.com/questions/44079328/python-load-module-in-parent-to-prevent-overwrite-problems

class loadVRMs:
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
        self.menu = self.tr(u'&loadVRMs')
        # TODO: We are going to let the user set this up in a future iteration
        self.toolbar = self.iface.addToolBar(u'loadVRMs')
        self.toolbar.setObjectName(u'loadVRMs')

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
        return QCoreApplication.translate('loadVRMs', message)


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
            text=self.tr(u'Load VMRs'),
            callback=self.run,
            parent=self.iface.mainWindow())

        # Need to set up signals for layerChanged

    def unload(self):
        """Removes the plugin menu item and icon from QGIS GUI."""
        for action in self.actions:
            self.iface.removePluginMenu(
                self.tr(u'&loadVRMs'),
                action)
            self.iface.removeToolBarIcon(action)
        # remove the toolbar
        del self.toolbar


    def run(self):
        """Run method that performs all the real work"""
        # show the dialog

        self.setupUi()
        self.dlg.show()
        # Run the dialog event loop
        result = self.dlg.exec_()

        # See if OK was pressed
        if result:

            surveysToProcess = self.itemList.getSelectedItems()

            # get folder for processing
            searchFolder = str(QFileDialog.getExistingDirectory(self.iface.mainWindow(), "Select Directory", QgsExpressionContextUtils.projectScope(QgsProject.instance()).variable('project_path')))

            TOMsMessageLog.logMessage("search folder is {} ...".format(searchFolder),
                                      level=Qgis.Warning)



            # https://stackoverflow.com/questions/3964681/find-all-files-in-a-directory-with-extension-txt-in-python
            for root, dirs, files in os.walk(searchFolder):
                for file in files:
                    if file.endswith(".gpkg"):
                        currGpkg = os.path.abspath(os.path.join(root, file))
                        TOMsMessageLog.logMessage("Processing {} ...".format(currGpkg), level=Qgis.Warning)

                        dbConn = QSqlDatabase.addDatabase("QSQLITE")
                        dbConn.setDatabaseName(currGpkg)
                        if not dbConn.open():
                            QMessageBox.critical(None, "Cannot open database",
                                                 "Unable to establish a database connection.\n\n"
                                                 "Click Cancel to exit.", QMessageBox.Cancel)
                        else:
                            self.processGpkg(dbConn, surveysToProcess)

                        dbConn.close()


    def processGpkg(self, dbConn, surveysToProcess):

        TOMsMessageLog.logMessage("In processGpkg ...", level=Qgis.Warning)

        # see if the table "RestrictionsInSurveys" exists
        tablesInCurrGpkg = dbConn.tables()

        if 'RestrictionsInSurveys' in tablesInCurrGpkg:
            TOMsMessageLog.logMessage("In processVRMs. RestrictionsInSurveys found ...", level=Qgis.Warning)

            for currSurveyItem in surveysToProcess:
                TOMsMessageLog.logMessage("Processing {} ...".format(currSurveyItem.text()), level=Qgis.Warning)
                currSurveyID = self.surveyDictionary[currSurveyItem.text()]
                TOMsMessageLog.logMessage("currSurveyID is {} ...".format(currSurveyID),
                                          level=Qgis.Warning)

                self.processVRMs(dbConn, currSurveyID)

    def processVRMs(self, dbConn, currSurveyID):
        TOMsMessageLog.logMessage("In processVRMs ...", level=Qgis.Warning)

        # relevant layers
        restrictionsInSurveysLayer = QgsProject.instance().mapLayersByName('restrictionsInSurveys')[0]
        VRMsLayer = QgsProject.instance().mapLayersByName('VRMs')[0]

        expr = QgsExpression("\"SurveyID\" = {}".format(currSurveyID))
        iterator = restrictionsInSurveysLayer.getFeatures(QgsFeatureRequest(expr))

        # update details in "RestrictionsInSurveys" layer

        queryQualifier = ''
        query = QSqlQuery(
        "SELECT SurveyID, GeometryID, DemandSurveyDateTime, Enumerator, Done, SuspensionReference, SuspensionReason, SuspensionLength, NrBaysSuspended, SuspensionNotes, Photos_01, Photos_02, Photos_03 FROM RestrictionsInSurveys WHERE SurveyID = {}".format(currSurveyID))
        query.exec()

        SurveyID, GeometryID, DemandSurveyDateTime, Enumerator, Done, \
        SuspensionReference, SuspensionReason, SuspensionLength, NrBaysSuspended, SuspensionNotes, \
        Photos_01, Photos_02, Photos_03 = range(13)

        #SurveyID, BeatTitle = range(2)  # ?? see https://realpython.com/python-pyqt-database/#executing-dynamic-queries-string-formatting

        while query.next():
            TOMsMessageLog.logMessage("In getCurrSurvey: currSurveyID: {}; surveyID: {}, BeatTitle: {}".format(currSurveyID, query.value(SurveyID), query.value(BeatTitle)), level=Qgis.Warning)
            surveyList.append(query.value(BeatTitle))
            surveyDictionary[query.value(BeatTitle)] = query.value(SurveyID)
            if int(currSurveyID) == int(query.value(SurveyID)):
                currSurveyName = query.value(BeatTitle)


                try:

                    currFeature[layer.fields().indexFromName(fieldName)] = value


                except Exception as e:

                    reply = QMessageBox.information(None, "Error",
                                                    "onAttributeChangedClass2. Update failed for: {}({}): {}; {}".format(
                                                        layer.name(), fieldName, value, e),
                                                    QMessageBox.Ok)  # rollback all changes

                # add details to "VRMs" layer



                """self.masterLayer = QgsProject.instance().mapLayersByName(currLayerItem.text())[0]
                #self.masterLayer = self.dlg.cb_layerMaster.currentLayer()

                #QMessageBox.information(self.iface.mainWindow(),"hello world","%s has %d features." %(self.masterLayer.name(),self.masterLayer.featureCount()))

                self.masterLayer.startEditing()

                TOMsMessageLog.logMessage("In loadOcc. masterLayer: " + str(self.masterLayer.name()),
                                         level=Qgis.Warning)

                #VRMfeatures = []
                masterFields = self.masterLayer.fields()

                #self.idxSurveyTime = self.masterLayer.fields().indexFromName("SurveyTime")
                self.idxSurveyID = self.masterLayer.fields().indexFromName(surveyIDField)

                try:
                    firstMaster = next(row for row in self.masterLayer.getFeatures())
                except StopIteration:
                    QMessageBox.information(self.iface.mainWindow(), "Checking time periods",  "No rows in " + self.masterLayer.name())
                    return

                currSurveyID = firstMaster[self.idxSurveyID]
                #currSurveyTime = firstMaster[self.idxSurveyTime]

                TOMsMessageLog.logMessage("In loadOcc. currSurveyID: " + str(currSurveyID),
                                         level=Qgis.Warning)

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

                            status = self.copyAttributes(feature, layer)
                            if status:
                                layerFeatureCount = layerFeatureCount + 1

                        parent = QgsProject.instance().layerTreeRoot().findLayer(layer.id()).parent().name()
                        TOMsMessageLog.logMessage(
                            "In loadOcc. count of records added within " + parent + ":" + layer.name() + ": " + str(layerFeatureCount),
                            level=Qgis.Warning)"""

                TOMsMessageLog.logMessage("In loadOcc. Now committing ... ",
                                         level=Qgis.Info)
                #self.masterLayer.commitChanges()

    def isCurrOcclayer(self, layer, currSurveyID, surveyIDField):

        # checks to see if this is a layer is for the correct survey period

        if layer != self.masterLayer:

            if layer.type() == QgsMapLayer.VectorLayer:
                TOMsMessageLog.logMessage("In isCurrOcclayer. considering layer: " + str(layer.name()),
                                         level=Qgis.Warning)

                for field in layer.fields():
                    if field.name() == "SurveyID":
                        try:
                            firstRow = next(row for row in layer.getFeatures())
                        except StopIteration:
                            TOMsMessageLog.logMessage(
                                "In isCurrOcclayer. Error checking survey time: " + str(layer.name()),
                                level=Qgis.Warning)
                            return False

                        TOMsMessageLog.logMessage("In isCurrOcclayer. layer: {}  has surveyID {}".format(layer.name(), str(firstRow.attribute("SurveyID"))),
                            level=Qgis.Warning)

                        if currSurveyID == firstRow.attribute(surveyIDField):
                            TOMsMessageLog.logMessage("In isCurrOcclayer. layer: " + str(layer.name() + " is for processing ..."),
                                                     level=Qgis.Warning)
                            return True

        return False

    def copyAttributes(self, feature, masterLayer):

        # copies relevant details into the master Layer

        status = True
        currAttribs = feature.attributes()

        pk_attr = "GeometryID"
        currGeometryID = feature.attribute(pk_attr)

        TOMsMessageLog.logMessage("In copyAttributes. GeometryID: " + str(currGeometryID),
                                 level=Qgis.Info)
        # Now find the row for this GeometryID in masterLayer
        query = ('"SurveyID" = {} AND "GeometryID" = \'{}\' AND ("Done" = \'false\' OR "Done" IS NULL)').format(currSurveyID, currGeometryID)
        expr = QgsExpression(query)
        selection = masterLayer.getFeatures(QgsFeatureRequest(expr))

        #masterIterator = (row for row in selection)
        try:
            masterRow = next(row for row in selection)
            rowFound = True
        except StopIteration:

            """TOMsMessageLog.logMessage("In copyAttributes. Error retrieving GeometryID: " + str(currGeometryID),
                                     level=Qgis.Info)"""
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

                    TOMsMessageLog.logMessage("In copyAttributes: Index error occurred updating field " + field + " in " + str(currGeometryID), level=Qgis.Warning)
                except KeyError:
                    #updStatus = self.masterLayer.changeAttributeValue(masterRow.id(), masterRow.fieldNameIndex(field), feature.attribute(idxCurrFieldValue))

                    TOMsMessageLog.logMessage("In copyAttributes. Key error occurred updating field " + field + " in " + str(currGeometryID), level=Qgis.Warning)

            status = masterLayer.updateFeature(masterRow)

            if status == False:
                QMessageBox.information(self.iface.mainWindow(), "In copyAttributes",  "Error occurred updating record surveyID {}, GeometryID {}:".format(currSurveyID, currGeometryID))

        else:
            TOMsMessageLog.logMessage("In copyAttributes: duplicate details for surveyID {}, GeometryID {}:".format(currSurveyID, currGeometryID), level=Qgis.Warning)
            return False
        #selection.close()

        return status

    def setupUi(self):

        self.dlg = QDialog()
        self.dlg.setWindowTitle("Import VRM data")
        self.dlg.setWindowModality(Qt.ApplicationModal)

        self.generalLayout = QVBoxLayout()

        layerGroup = QGroupBox("Choose time periods to import")
        # test = QLabel()
        # test.setText("Choose layers to export and confirm location of output")
        # self.generalLayout.addWidget(test)

        surveyList = list()
        self.surveyDictionary = {}
        surveysLayer = QgsProject.instance().mapLayersByName('Surveys')[0]
        surveysIterator = surveysLayer.getFeatures()

        for currSurvey in surveysIterator:
            currSurvey.attribute("BeatTitle")
            surveyList.append(currSurvey.attribute("BeatTitle"))
            self.surveyDictionary[currSurvey.attribute("BeatTitle")] = currSurvey.attribute("SurveyID")

        # add map layer list
        self.itemList = checkableList(sorted(surveyList))
        vbox1 = QVBoxLayout()
        vbox1.addWidget(self.itemList)
        layerGroup.setLayout(vbox1)
        self.generalLayout.addWidget(layerGroup)

        # add file chooser
        #outputGroup = QGroupBox("Choose output file")
        #self.fileNameWidget = QgsFileWidget()
        #self.fileNameWidget.setStorageMode(QgsFileWidget.SaveFile)
        #self.fileNameWidget.setFilter("Geopackage (*.gpkg);;JPEG (*.jpg *.jpeg);;TIFF (*.tif)")
        #self.fileNameWidget.setSelectedFilter("Geopackage (*.gpkg)")
        #vbox2 = QVBoxLayout()
        #vbox2.addWidget(self.fileNameWidget)
        #outputGroup.setLayout(vbox2)
        #self.generalLayout.addWidget(outputGroup)

        # add buttons
        self.buttonBox = QDialogButtonBox(QDialogButtonBox.Ok
                                          | QDialogButtonBox.Cancel)
        self.buttonBox.accepted.connect(self.dlg.accept)
        self.buttonBox.rejected.connect(self.dlg.reject)
        self.generalLayout.addWidget(self.buttonBox)

        self.dlg.setLayout(self.generalLayout)
        checkableListCtrl(self.itemList)


class checkableListCtrl:
    """PyCalc Controller class."""
    def __init__(self, view):
        """Controller initializer."""
        self._view = view
        # Connect signals and slots
        self._connectSignals()

    def _connectSignals(self):
        """Connect signals and slots."""
        self._view.select_all_cb.clicked.connect(lambda: self._view.selectAllCheckChanged(self._view.select_all_cb, self._view.model))
        self._view.view.clicked.connect(lambda: self._view.listviewCheckChanged(self._view.model, self._view.select_all_cb))
        self._view.view.clicked[QModelIndex].connect(self._view.updateSelectedItems)

class checkableList(QWidget):

    # create a checkable list of the items

    def __init__(self, listToUse, parent=None):
        QWidget.__init__(self, parent)

        #itemList = listToUse
        #self.iface = iface

        """for layer in itemList:
            print(layer.name())"""

        self.selectedItems = []

        layout = QVBoxLayout()
        self.model = QStandardItemModel()

        self.select_all_cb = QCheckBox('Check All')
        self.select_all_cb.setChecked(True)
        self.select_all_cb.setStyleSheet('margin-left: 5px; font: bold')
        #self.select_all_cb.stateChanged.connect(lambda: selectAllCheckChanged(select_all_cb, model))
        layout.addWidget(self.select_all_cb)

        self.view = QListView()
        self.view.setEditTriggers(QAbstractItemView.NoEditTriggers)
        self.view.setSelectionMode(QAbstractItemView.NoSelection)
        self.view.setSelectionRectVisible(False)

        for itemFromList in listToUse:
            item = QStandardItem(itemFromList)
            # item.setFlags(Qt.ItemIsUserCheckable | Qt.ItemIsEnabled)
            # item.setData(QVariant(Qt.Checked), Qt.CheckStateRole)
            item.setCheckable(True)
            item.setSelectable(False)
            item.setCheckState(QtCore.Qt.Checked)
            self.model.appendRow(item)
            self.selectedItems.append(item)

        self.view.setModel(self.model)

        #view.clicked.connect(lambda: listviewCheckChanged(item, model, select_all_cb))

        layout.addWidget(self.view)

        self.setLayout(layout)
        """if parent:
            parent.setLayout(layout)
        else:
            window = QWidget()
            window.setLayout(layout)"""
        #window.show()

    def selectAllCheckChanged(self, select_all_cb, model):
        TOMsMessageLog.logMessage("IN selectAllCheckChanged",
                                 level=Qgis.Warning)
        for index in range(model.rowCount()):
            item = model.item(index)
            if item.isCheckable():
                if select_all_cb.isChecked():
                    item.setCheckState(QtCore.Qt.Checked)
                    self.selectedItems.append(item)
                else:
                    item.setCheckState(QtCore.Qt.Unchecked)
                    self.selectedItems.remove(item)

        TOMsMessageLog.logMessage("IN selectAllCheckChanged: len list {}".format(len(self.selectedItems)),
                                  level=Qgis.Warning)

    def listviewCheckChanged(self, model, select_all_cb):
        ''' updates the select all checkbox based on the listview '''
        # model = self.listview.model()
        TOMsMessageLog.logMessage("IN listviewCheckChanged",
                                 level=Qgis.Warning)
        items = [model.item(index) for index in range(model.rowCount())]
        if all(item.checkState() == QtCore.Qt.Checked for item in items):
            select_all_cb.setTristate(False)
            select_all_cb.setCheckState(QtCore.Qt.Checked)
        elif any(item.checkState() == QtCore.Qt.Checked for item in items):
            select_all_cb.setTristate(True)
            select_all_cb.setCheckState(QtCore.Qt.PartiallyChecked)
        else:
            select_all_cb.setTristate(False)
            select_all_cb.setCheckState(QtCore.Qt.Unchecked)

    def updateSelectedItems(self, index):
        #QMessageBox.information(self.iface.mainWindow(), "debug", "IN updateSelectedLayers: {}".format(self.model.itemFromIndex(index)))
        TOMsMessageLog.logMessage("IN updateSelectedItems: {}".format(index) ,
                                 level=Qgis.Warning)
        item = self.model.itemFromIndex(index)
        if item.checkState() == QtCore.Qt.Checked:
            self.selectedItems.append(item)
        else:
            self.selectedItems.remove(item)

    def getSelectedItems(self):
        return self.selectedItems

