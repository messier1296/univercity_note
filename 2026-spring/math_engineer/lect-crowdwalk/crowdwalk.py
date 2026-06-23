#!/usr/bin/python
# -*- coding: utf-8 -*-

import subprocess
import codecs
import csv
import json
import os
import shutil
from pathlib import Path


def require_command(command):
	if shutil.which(command) is None:
		raise RuntimeError(f"{command} is not found. Please install JDK 17.")


def setup():
	require_command("javac")

	# Build Crowdwalk
	gradle_home = Path("work/.gradle")
	gradle_home.mkdir(parents=True, exist_ok=True)
	env = os.environ.copy()
	env["GRADLE_USER_HOME"] = str(Path.cwd() / gradle_home)
	subprocess.check_call(
		["sh", "./gradlew", "build"],
		cwd="CrowdWalk-master/crowdwalk",
		env=env
	)


def clean():
	gradle_home = Path("work/.gradle")
	gradle_home.mkdir(parents=True, exist_ok=True)
	env = os.environ.copy()
	env["GRADLE_USER_HOME"] = str(Path.cwd() / gradle_home)
	subprocess.check_call(
		["sh", "./gradlew", "clean"],
		cwd="CrowdWalk-master/crowdwalk",
		env=env
	)


def run(prop_path='scenario/shinkoku/prop.json', use_gui=True):
	if not Path('CrowdWalk-master/crowdwalk/build/libs/crowdwalk.jar').exists():
		print("Setup CrowdWalk (Please wait a minute)")
		setup()

	require_command("java")

	with open(prop_path) as f:
		prop = json.load(f)
	log_path = Path(prop_path).parent / prop['agent_movement_history_file']
	if log_path.exists():
		log_path.unlink()

	ui_flag = '-g' if use_gui else '-c'
	proc = subprocess.Popen(['sh', 'CrowdWalk-master/crowdwalk/quickstart.sh', '-l', 'Error', ui_flag, prop_path])
	proc.wait()

	if proc.returncode != 0:
		raise RuntimeError("Simulation Error")

	with codecs.open(log_path, 'r', 'utf_8') as f:
		reader = csv.DictReader(f)
		log = [row for row in reader]
	return int(log[-1]['到着時刻2'])
