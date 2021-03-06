(in-package :cl-user)
(defpackage markedit
  (:use :cl :lucerne)
  (:import-from :ceramic.resource
                :define-resources
                :resource-directory)
  (:export :app)
  (:documentation "Main MarkEdit code."))
(in-package :markedit)
(annot:enable-annot-syntax)

;;; App resources

(define-resources :markedit ()
  (assets #p"assets/")
  (templates #p"templates/"))

;;; App

(defapp app
  :middlewares ((clack.middleware.static:<clack-middleware-static>
                 :root (resource-directory 'assets)
                 :path "/static/")))

;;; Templates

(djula:add-template-directory
 (resource-directory 'templates))

(defparameter +index+
  (djula:compile-template* "index.html"))

;;; Views

(defun markdown-to-html (string)
  (with-output-to-string (stream)
    (let ((3bmd-code-blocks:*code-blocks* t)
          (3bmd:*smart-quotes* t))
      (3bmd:parse-string-and-print-to-stream string stream))))

@route app "/"
(defview index ()
  "The index page displays the editor."
  (render-template (+index+)))

@route app (:post "/to-html")
(defview to-html ()
  "This part of the API receives Markdown and emits HTML"
  (with-params (markdown)
    (respond (markdown-to-html markdown))))

;;; Startup

(defparameter *port* 9000)

(ceramic:define-entry-point :markedit ()
  (start app :port *port*)
  (let ((window (ceramic:make-window :url (format nil "http://localhost:~D/" *port*))))
    (ceramic:show window)))
