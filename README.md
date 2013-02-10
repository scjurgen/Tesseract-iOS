Tesseract-iOS
=============

Tesseract OCR on iOS (6.1++),

Just putting together the bits and bytes to include OCR in an iOS application.
This project is by no means target to obtain a commercial project but should 
serve as a jump board to create your own OCR aware iOS app.

It is based on Tesseract and leptonic.


see also install_newest.txt to understand what to do if you want to compile 
the 2 libraries on your own (not a trivial task).


Run unittest for regression testing (the results are predictable so TDD is a must here).

Issues: if you press many times the next button you enqueue many calculations, 
there is no "empty-queue-mechanism".