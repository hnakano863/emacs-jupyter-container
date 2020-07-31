;;; emacs-jupyter-container -- Hooks to use containerized kernels from Org-Babel  -*- lexical-binding: t -*-

;; Author: Hiroshi Nakano <notchi863@gmail.com>
;; URL: https://github.com/hnakano863/emacs-jupyter-container
;; Keywords: docker, jupyter, python
;; Version: 0.0.1
;; Package-Requires: ((emacs "26") (docker.el "1.3"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; This package provides hooks to use docker containerised jupyter kernels from org-babel src block

;;; Code:

(require 'docker-core)

(defun jupyter-container-org-run-hook ()
  "Run a containerized kernel."
  (docker-run-docker-async "run"
                           "--name jupyter"
                           "-it"
                           "--rm"
                           "-d"
                           "-p 56406-56410:56406-56410"
                           "jupyter/scipy-notebook"
                           "start.sh jupyter-kernel"
                           "--ip=0.0.0.0"
                           "--KernelManager.control_port=56406"
                           "--KernelManager.hb_port=56407"
                           "--KernelManager.iopub_port=56408"
                           "--KernelManager.shell_port=56409"
                           "--KernelManager.stdin_port=56410"
                           "--KernelManager.connection_file=conn.json")
  (setf (alist-get :session
                   org-babel-default-header-args:jupyter-python)
        "/docker:jupyter:/home/jovyan/conn.json"))

(defun jupyter-container-org-kill-hook ()
  "Kill a container."
  (docker-run-docker-async "kill jupyter")
  (setf (alist-get :session
                   org-babel-default-header-args:jupyter-python)
        "py"))

(provide 'jupyter-container)

;;; jupyter-container ends here
