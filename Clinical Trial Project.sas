libname ctm 'C:\Users\nwalker\Google Drive\Spring 17 Homework\Homework\CTM\hw2';

/*import copy/paste data from homework*/
data ctm.hw2;
	input pat trt $ DBP1 DBP2 DBP3 DBP4 DBP5;
	cards;
 1  D 	110 	112 	115 	110 	105
 2 	D 	116 	113 	112 	103 	101
 3 	D 	119 	115 	113 	104 	98
 4 	D 	115 	115 	112 	110 	100
 5 	D 	116 	112 	107 	104 	105
 6 	D 	117 	115 	113 	106 	102
 7 	D 	118 	111 	100 	109 	99
 8 	D 	120 	116 	113 	108 	100
 9 	D 	114 	112 	113 	109 	103
10 	D 	115 	113 	108 	106 	97
11 	D 	117 	112 	110 	109 	101
12 	D 	115 	114 	112 	109 	102
13 	D 	119 	117 	110 	106 	104
14 	D 	118 	115 	113 	102 	99
15 	D 	115 	112 	108 	105 	102
16 	D 	114 	111 	111 	107 	100
17 	D 	118		114 	110 	108 	100
18 	D 	120 	115 	113 	107 	103
19 	D 	114 	113 	109 	104 	100
20 	D 	110 	108 	106 	104 	101
21 	P 	118 	115 	113 	111 	113
22 	P 	116 	114 	113 	109 	110
23 	P 	114 	115 	113 	112 	109
24 	P 	114 	115 	113 	114 	115
25 	P 	115 	113 	113 	109 	109
26 	P 	114 	115 	114 	111 	111
27 	P 	119 	118 	118 	117 	115
28 	P 	118 	117 	117 	116 	112
29 	P 	114 	113 	113 	110 	111
30 	P 	120 	115 	113 	113 	113
31 	P 	117 	115 	113 	114 	117
32 	P 	118 	114 	112 	110 	109
33 	P 	121 	119 	117 	114 	115
34 	P 	116 	115 	116 	114 	111
35 	P 	118 	118 	113 	113 	112
36 	P 	119 	115 	115 	114 	111
37 	P 	116 	114 	113 	109 	108
38 	P 	116 	115 	114 	114 	110
39 	P 	120 	115 	113 	114 	115
40 	P 	125 	116 	114 	114 	116
;
run;

/*Objective 1: Plot graph of each level of trt: mean, lcl95, ucl95*/
/*get all means and confidence intervals*/
PROC MEANS data=ctm.hw2 alpha=0.05 mean lclm uclm noprint;
	var DBP1 DBP2 DBP3 DBP4 DBP5;
	by trt; 
	output out=ctm.means /*output each mean and CI into new DS*/
		mean(DBP1)=mean1 
		lclm(DBP1)=lclm1 
		uclm(DBP1)=uclm1
		mean(DBP2)=mean2 
		lclm(DBP2)=lclm2 
		uclm(DBP2)=uclm2
		mean(DBP3)=mean3 
		lclm(DBP3)=lclm3 
		uclm(DBP3)=uclm3
		mean(DBP4)=mean4 
		lclm(DBP4)=lclm4 
		uclm(DBP4)=uclm4
		mean(DBP5)=mean5
		lclm(DBP5)=lclm5 
		uclm(DBP5)=uclm5
		mean=meanall
		lclm=lclmall
		uclm=uclmall;
run;

/*rearrange new DS by visit*/
data ctm.means2;
	set ctm.means;
		array means {5} mean1 - mean5; /*Put each variable into an array for outputting*/
		array lclms {5} lclm1 - lclm5;
		array uclms {5} uclm1 - uclm5;
	if trt = "D" then /*Output for drug*/
	do i = 1 to 5;
		trt = trt;
		visit = i;
		mean = means{i};
		uclm = uclms{i};
		lclm = lclms{i};
		output;
	end;
	if trt = "P" then /*Output for placebo*/
	do i = 1 to 5;
		trt = trt;
		visit = i;
		mean = means{i};
		uclm = uclms{i};
		lclm = lclms{i};
		output;
	end;
	keep trt visit mean uclm lclm; /*Remove redundant variables*/
run;

proc print data=ctm.means2;
	title "Visit Summaries";
	var _all_;
run;

data ctm.means3;
	set ctm.means2;
	by trt visit;

	/*offset x values so they don't overlap*/
	if trt = "D" then xvar = visit - .05;
	else if trt = "P" then xvar = visit + .05;

	/*output uclm and lclm separately for vertical lines*/
	yvar = uclm;
	output;
	yvar = lclm;
	output;

	keep trt xvar yvar mean visit;
run;


/*plot mean and 95% CI by Drug/Placebo by visit*/
goptions reset=all cback=white border htext=10pt htitle=12pt;  /*reset options*/

TITLE "Mean and 95% CI of DBP by Visit"; /*graph title*/

symbol1 interpol=hilo color=vibg line=1; /*set vertical lines for confidence intervals*/
symbol2 interpol=hilo color=depk line=2;

symbol3 interpol=join color=vibg value=diamond height=1; /*set horizontal lines for means*/
symbol4 interpol=join color=depk value=diamond height=1;

axis1 order=(0 to 6 by 1) label=(H=1 "Visits") /*set axis labels*/
	minor=none
	value=(t=1 "" 
		t=2 "Baseline" 
		t=3 "Follow-up 1" 
		t=4 "Follow-up 2" 
		t=5 "Follow-up 3" 
		t=6 "Final Follow-up"
		t=7 ""
		angle=45);
axis2 label=(H=1 "Diastolic Blood Pressure (DBP)");
Legend1 label=none value=(H=1 "Treatment" "Placebo") frame; /*set legend*/

/*Plot data and overlay*/
proc gplot data=ctm.means3;
	plot yvar*xvar=trt / haxis = axis1 vaxis = axis2 legend=legend1;
	plot2 mean*xvar=trt / vaxis=axis2 noaxis nolegend;
run;
quit;
/*reset plot options*/
goptions reset=all cback=white border htext=10pt htitle=12pt;

/*Objective 2: Transform data set to produce new set with variables Pat, Trt, DBP, and Visit*/
data ctm.main;
	set ctm.hw2;
	array dbpvar {5} DBP1 - DBP5; /*put each visit var into array*/
	do i = 1 to 5; /*for every observation, make 5 outputs corresponding to visit in array*/
		pat = pat;
		trt = trt;
		dbp = dbpvar{i};
		visit = i;
		output;
	end;
	keep pat trt dbp visit; /*drop unneeded variables*/
run;

/*view long data*/
proc print data=ctm.main;
	title "Long Data";
	var pat trt dbp visit;
run;

/*Objective 3: Analyze DBP using change from baseline as the response variable to address
				the question: Is D better than P in terms of lowering DBP?*/

/*assure sorting by patient and visit*/
proc sort data=ctm.main;
	by pat visit ;
run;

/*create difference from baseline*/
data ctm.obj3;
	set ctm.main;
	if visit = 1 then baseline = dbp; /*set baseline by patient*/
		retain baseline; /*retain baseline by patient*/
		diffbase = dbp-baseline; /*create difference*/
	title "Difference between visit and baseline DBP";
run;

/*sort by visit*/
proc sort data=ctm.obj3;
	by visit trt;
run;

/*find difference means*/
proc means data=ctm.obj3 mean uclm lclm alpha=0.05;
	title "difference by visit";
	var diffbase;
	by visit trt;
run;

/*run ANOVA for visit1-visit(2:5) for trt visit trt*visit*/
proc glm data=ctm.obj3;
	title "Difference: Check for Interaction";
	class trt visit;
	model diffbase = trt|visit / solution e; /*look at interaction term sig*/
run;
quit;


/*compare each visit with baseline*/
/*note overall alpha = 0.05, but bonferroni adjustment by 4 makes them 0.0125*/
proc glm data=ctm.obj3;
	title "Difference for Visit 2";
	where visit = 2;
	class trt;
	model diffbase = trt;
	lsmeans trt / cl alpha=0.0125 adjust=bon pdiff=controll('P');
run;

proc glm data=ctm.obj3;
	title "Difference for Visit 3";
	where visit = 3;
	class trt;
	model diffbase = trt;
	lsmeans trt / cl alpha=0.0125 adjust=bon pdiff=controll('P');
run;

proc glm data=ctm.obj3;
	title "Difference for Visit 4";
	where visit = 4;
	class trt;
	model diffbase = trt;
	lsmeans trt / cl alpha=0.0125 adjust=bon pdiff=controll('P');
run;

proc glm data=ctm.obj3;
	title "Difference for Visit 5";
	where visit = 5;
	class trt;
	model diffbase = trt;
	lsmeans trt / cl alpha=0.0125 adjust=bon pdiff=controll('P'); /*this is the answer for Objective 4*/
run;

/*Objective 4: Analyze DBP using change from baseline at the end of treatment (Visit 5)
				as the response variable to address the question: Is D better than 
				P in terms of lowering DBP?*/

/*answer above*/


/*Objective 5: Analyze DBP using change from baseline as the response variable and baseline
				DBP as a covariate to address the question: Is D better than P in terms 
				of lowering DBP?*/

/*run ANOVA for visit1-visit(2:5) for trt visit trt*visit*/
proc glm data=ctm.obj3;
	title "Test for Interaction with Covariate";
	class trt visit;
	model diffbase = trt visit baseline trt*visit visit*baseline trt*baseline/ solution e; /*look at interaction term sig*/
run;
quit;


/*Check for difference at individual levels*/
proc glm data=ctm.obj3;
	title "Test for Difference at Visit 2";
	where visit = 2;
	class trt;
	model diffbase = trt baseline; /*look at interaction term sig*/
	lsmeans trt / cl alpha=0.0125 adjust=bon pdiff=controll('P'); /*one-sided test with Ho: P<D Ha: P>D*/
run;
quit;

proc glm data=ctm.obj3;
	title "Test for Difference at Visit 3";
	where visit = 3;
	class trt;
	model diffbase = trt baseline; /*look at interaction term sig*/
	lsmeans trt / cl alpha=0.0125 adjust=bon pdiff=controll('P'); /*one-sided test with Ho: P<D Ha: P>D*/
run;
quit;

proc glm data=ctm.obj3;
	title "Test for Difference at Visit 4";
	where visit = 4;
	class trt;
	model diffbase = trt baseline; /*look at interaction term sig*/
	lsmeans trt / cl alpha=0.0125 adjust=bon pdiff=controll('P'); /*one-sided test with Ho: P<D Ha: P>D*/
run;
quit;

proc glm data=ctm.obj3;
	title "Test for Difference at Visit 5";
	where visit = 5;
	class trt;
	model diffbase = trt baseline; /*look at interaction term sig*/
	lsmeans trt baseline / cl alpha=0.0125 adjust=bon pdiff=controll('P'); /*one-sided test with Ho: P<D Ha: P>D*/
run;
quit;

/*Objective 6: Analyze DBP using change from baseline at the end of treatment (Visit 5)
				as the response variable and baseline DBP as a covariate to address the 
				question: Is D better than P in terms of lowering DBP?*/

/*answer is in O5, looking at visit 5*/

