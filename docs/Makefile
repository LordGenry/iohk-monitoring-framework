DOC1 = IOHK-Monitoring-code
DOC2 = IOHK-Monitoring-tests

SOURCES = ../src/Code.lhs \
					../src/Cardano/BM/ \
					../src/Cardano/BM/Aggregated.lhs \
					../src/Cardano/BM/BaseTrace.lhs \
					../src/Cardano/BM/Configuration.lhs \
					../src/Cardano/BM/Configuration/Model.lhs \
					../src/Cardano/BM/Configuration/View.lhs \
					../src/Cardano/BM/Counters.lhs \
					../src/Cardano/BM/Counters/Common.lhs \
					../src/Cardano/BM/Counters/Dummy.lhs \
					../src/Cardano/BM/Counters/Linux.lhs \
					../src/Cardano/BM/Data/Backend.lhs \
					../src/Cardano/BM/Data/Configuration.lhs \
					../src/Cardano/BM/Data/Counter.lhs \
					../src/Cardano/BM/Data/LogItem.lhs \
					../src/Cardano/BM/Data/Observable.lhs \
					../src/Cardano/BM/Data/Output.lhs \
					../src/Cardano/BM/Data/Rotation.lhs \
					../src/Cardano/BM/Data/Severity.lhs \
					../src/Cardano/BM/Data/SubTrace.lhs \
					../src/Cardano/BM/Data/Trace.lhs \
					../src/Cardano/BM/Observer/Monadic.lhs \
					../src/Cardano/BM/Observer/STM.lhs \
					../src/Cardano/BM/Output/Aggregation.lhs \
					../src/Cardano/BM/Output/EKGView.lhs \
					../src/Cardano/BM/Output/Log.lhs \
					../src/Cardano/BM/Output/Switchboard.lhs \
					../src/Cardano/BM/Setup.lhs \
					../src/Cardano/BM/Trace.lhs \

TESTS = ../test/Test.lhs \
				../test/Cardano/BM/Test/Aggregated.lhs \
				../test/Cardano/BM/Test/Trace.lhs \
				../test/Cardano/BM/Test/STM.lhs \
				../test/Cardano/BM/Arbitrary/Aggregated.lhs \

ImagePdf = OverviewModules.pdf SetupProcedure.pdf ConfigurationModel.pdf

.PHONY: $(DOC1).pdf all clean

all: $(DOC1).pdf $(DOC2).pdf

$(DOC1).tex: $(SOURCES)
	cd ../src; lhs2TeX -v -o ../docs/$(DOC1).tex Code.lhs

$(DOC2).tex: $(TESTS) test-coverage.tex
	cd ../test; lhs2TeX -v -o ../docs/$(DOC2).tex Test.lhs

$(DOC1).pdf: $(DOC1).tex $(ImagePdf)
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make $(DOC1).tex

$(DOC2).pdf: $(DOC2).tex
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make $(DOC2).tex

OverviewModules.pdf: OverviewModules.png
	convert $< $@

SetupProcedure.pdf: SetupProcedure.png
	convert $< $@

ConfigurationModel.pdf: ConfigurationModel.png
	convert $< $@

clean:
	latexmk -CA

