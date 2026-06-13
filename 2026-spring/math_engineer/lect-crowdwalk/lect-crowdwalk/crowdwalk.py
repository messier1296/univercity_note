#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import subprocess
import codecs
import csv
import json
import stat
from pathlib import Path

def setup():
	# Check JDK and install
	try:
		subprocess.check_call(["javac","-version"])
	except:
		print("Setup OpenJDK (Please wait a minute)")
		subprocess.call("conda install openjdk -y")
		try:
			subprocess.check_call(["javac","-version"])
		except:
			print("JDK is not found")
			exit()

	# Build Crowdwalk
	cwd = os.getcwd()
	os.chdir("CrowdWalk-master/crowdwalk")
	if os.name != 'nt':
		gradlew = Path("./gradlew")
		gradlew.chmod(gradlew.stat().st_mode | stat.S_IXUSR)
	subprocess.call(["./gradlew","build"])
	os.chdir(cwd)


def clean():
	cwd = os.getcwd()
	os.chdir("CrowdWalk-master/crowdwalk")
	subprocess.call("gradlew.bat clean")
	os.chdir(cwd)


def run(prop_path='scenario/shinkoku/prop.json', use_gui=True):
	if not os.path.exists('CrowdWalk-master/crowdwalk/build/libs/crowdwalk.jar'):
		print("Setup CrowdWalk (Please wait a minute)")
		setup()

	try:
		subprocess.check_call(["java","-version"])
	except:
		setup()
		try:
			subprocess.check_call(["java","-version"])
		except:
			print("JDK is not found")
			exit()

	with open(prop_path) as f:
		prop = json.load(f)
	log_path = Path(prop_path).parent / prop['agent_movement_history_file']
	if os.path.exists(log_path):
		os.remove(log_path)

	ui_flag = '-g' if use_gui else '-c'
	jar_path = 'CrowdWalk-master/crowdwalk/build/libs/crowdwalk.jar'
	if os.name == 'nt':
		cmd = ['CrowdWalk-master/crowdwalk/quickstart.bat', '-l', 'Error', ui_flag, prop_path]
	else:
		cmd = ['java', '-Dfile.encoding=UTF-8', '-jar', jar_path, '-l', 'Error', ui_flag, prop_path]
	proc = subprocess.Popen(cmd)
	proc.wait()

	if proc.returncode != 0:
		raise RuntimeError("Simulation Error")

	with codecs.open(log_path, 'r', 'utf_8') as f:
		reader = csv.DictReader(f)
		log = [row for row in reader]
	return int(log[-1]['到着時刻2'])
