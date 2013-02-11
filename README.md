Tesseract-iOS
=============

Tesseract OCR (3.0.2) on iOS (6.1++),

Just putting together the bits and bytes to include OCR in an iOS application.
Readonly mode, no training.

This project is by no means targetted to obtain a commercial product but should
serve as a jump board to create your own OCR aware iOS app.

It is based on Tesseract and Leptonic:
http://code.google.com/p/tesseract-ocr/
http://leptonica.com/ for some of the image processing parts.

See also install_newest.txt to understand what to do if you want to compile the 2 libraries on your own (it is not necessarily a trivial task and might anytime break as it envolves a lot of stuff).

Run unittest for regression testing, the results are predictable so TDD is a YES here. But we are dealing with a particualr kind of test as it also affects the quality and not only a boolean win/fail.
Some tests will fail in this version (that depends on the traineddata and the fonts used in the image).
This is not necessarily a bad thing.

Issues: if you call many times the analyseImage method you keep enqueueing calculations, 
there is no "empty-queue-mechanism".

