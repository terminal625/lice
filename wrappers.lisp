;;; A collection of wrappers around extended functionality that may be
;;; different across CL implementations.

;;; To add support for a new CL implementation, an entry in each of
;;; these functions must be made for it.

(in-package :lice)

;;; Weak Pointers

(defun weak-pointer-p (wp)
  #+clisp (ext:weak-pointer-p (wp))
  #-(or clisp) (declare (ignore wp)))

(defun make-weak-pointer (data)
  #+clisp (ext:make-weak-pointer data)
  #+cmu (extensions:make-weak-pointer data)
  #+sbcl (sb-ext:make-weak-pointer data)
  #+(or movitz mcl) data)

(defun weak-pointer-value (wp)
  #+clisp (ext:weak-pointer-value wp)
  #+cmu (extensions:weak-pointer-value wp)
  #+sbcl (sb-ext:weak-pointer-value wp)
  #+(or movitz mcl) (values wp t))

;;; Some wrappers for access to filesystem things. file type, file
;;; size, ownership, modification date, mode, etc

(defun file-stats (pathname)
  "Return some file stats"
  #+sbcl
  (let ((stat (sb-posix:lstat pathname)))
    (values (sb-posix:stat-mode stat)
	    (sb-posix:stat-size stat)
	    (sb-posix:stat-uid stat)
	    (sb-posix:stat-gid stat)
	    (sb-posix:stat-mtime stat)))
  #+clisp
  (let ((stat (sys::file-stat pathname)))
    (values (butlast (sys::file-stat-mode stat))
	    (sys::file-stat-size stat)
	    (sys::file-stat-uid stat)
	    (sys::file-stat-gid stat)
	    (sys::file-stat-mtime stat)))
  #-(or sbcl clisp)
  (error "Not implemented"))

(provide :lice-0.1/wrappers)

