#!/bin/bash
cd /opt/conda/lib/python3.10/site-packages/
cat > /mnt/dominojobtask-cache-fix.patch <<EOL
From 0b69b1ebe4b1a270bb8484895e53c43700e59e36 Mon Sep 17 00:00:00 2001
From: ddl-rliu <richard.liu@dominodatalab.com>
Date: Tue, 25 Jun 2024 14:52:09 -0700
Subject: [PATCH] Add more configuration to TaskMetadata

---
 flytekitplugins/domino/task.py | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/flytekitplugins/domino/task.py b/flytekitplugins/domino/task.py
index 58055cc..e6fbc50 100644
--- a/flytekitplugins/domino/task.py
+++ b/flytekitplugins/domino/task.py
@@ -3,7 +3,7 @@ import os
 from dataclasses import dataclass
 from datetime import timedelta
 from enum import Enum
-from typing import Any, Dict, List, Optional, Type
+from typing import Any, Dict, List, Optional, Tuple, Type, Union
 
 import requests
 import rich_click as click
@@ -284,6 +284,12 @@ class DominoJobTask(AsyncAgentExecutorMixin, PythonTask[DominoJobConfig]):
         inputs: Optional[Dict[str, Type]] = None,
         outputs: Optional[Dict[str, Type]] = None,
         log_level: int = 20,  # 20 is info, 30 is warning, etc
+        cache: bool = False,
+        cache_serialize: bool = False,
+        cache_version: str = "",
+        cache_ignore_input_vars: Tuple[str, ...] = (),
+        retries: int = 0,
+        timeout: Union[timedelta, int] = timedelta(hours=3),
         **kwargs,
     ):
         if use_latest:
@@ -309,7 +315,14 @@ class DominoJobTask(AsyncAgentExecutorMixin, PythonTask[DominoJobConfig]):
             interface=Interface(inputs=inputs, outputs=outputs),
             inputs=inputs,
             outputs=outputs,
-            metadata=TaskMetadata(retries=0, timeout=timedelta(hours=3)),
+            metadata=TaskMetadata(
+                cache=cache,
+                cache_serialize=cache_serialize,
+                cache_version=cache_version,
+                cache_ignore_input_vars=cache_ignore_input_vars,
+                retries=retries,
+                timeout=timeout,
+            ),
             **kwargs,
         )
         # Interface class passed into task constructor doesn't have to_flyte_idl() so can't seem to get the correct base64 vals before instantiating the task.
-- 
2.44.0
EOL
patch flytekitplugins/domino/task.py < /mnt/dominojobtask-cache-fix.patch
if [ $? -eq 0 ]; then
    echo "Patch applied successfully"
else
    echo "Failed to apply patch"
fi