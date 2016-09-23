#!/usr/bin/python

import os

def removeFabricFromPlist():
	f = open("ChatDemo-UI3.0/ChatDemo-UI3.0-Info.plist", 'r+')
	count = 0
	totalCount = 13
	lines = f.readlines()
	f.seek(0)
	f.truncate()
	
	removeLine = False
	for line in lines:
		if line.find('<key>Fabric</key>') != -1:
			removeLine = True
			print line
			continue
		if removeLine == True and count < totalCount:
			count += 1
			print line
			continue
		f.write(line)
	f.close()

def removeFabricFromAppDelegate():
	f = open("ChatDemo-UI3.0/Class/AppDelegate.m", 'r+')
	lines = f.readlines()
	f.seek(0)
	f.truncate()
	
	for line in lines:
		if line.find('Fabric') != -1:
			print line
			continue
		if line.find('Crashlytics') != -1:
			print line
			continue
		f.write(line)
	f.close()

def writeSection(f, lines):
	for line in lines:
		f.write(line)

def removeFabricFromProject():
	f = open("ChatDemo-UI3.0.xcodeproj/project.pbxproj", 'r+')
	lines = f.readlines()
	f.seek(0)
	f.truncate()
	
	sectionLines = []
	sectionBegin = False
	isFabricSection = False
	for line in lines:
		if sectionBegin == False:
			if line.find('Fabric') != -1:
				print line
				continue
			if line.find('Crashlytics') != -1:
				print line
				continue
			if line.find('28B2239B1D549488006FA0C6 /* ShellScript */,') != -1:
				print line
				continue
			if line.find('/* Begin PBXShellScriptBuildPhase section */') != -1:
				sectionBegin = True
				sectionLines.append(line)
				continue
		else:
			sectionLines.append(line)
			if line.find('28B2239B1D549488006FA0C6 /* ShellScript */ = {') != -1:
				isFabricSection = True
			elif line.find('/* End PBXShellScriptBuildPhase section */') != -1:
				if isFabricSection == False:
					writeSection(f, sectionLines)
				else:
					for sectionLine in sectionLines:
						print sectionLine
				isFabricSection = False
				sectionBegin = False
				del sectionLines[:]
			continue
		f.write(line)
	f.close()

def removeFrameWorks():
	os.system('rm -rf Fabric.framework')
	os.system('rm -rf Crashlytics.framework')

def main():
	removeFabricFromPlist()
	removeFabricFromAppDelegate()
	removeFabricFromProject()
	removeFrameWorks()

if __name__ == '__main__':
	main()