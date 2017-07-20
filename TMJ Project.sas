/************************************Raw Data Changes************************************************************************/
*1. Removed period in observation #92, Column C (should have been comma) and removed commas from Column C: "Number of views"
*2. Removed spurious data from unnamed Column AC
*3. Replaced all remaining commas with periods (all were in character columns)
*4. Changed/Shortened names of Columns F through AB to ease SAS import
*5. Saved as CSV (MS-DOS)
*6. Opened CSV in WordPad and manually changed values in Column E: "Length of video" to match HH:MM:SS convention, 
*   as some values were simply MM:SS and being imported into SAS as HH:MM(:SS);
/****************************************************************************************************************************/

/******************************************************************Data Import*********************************************************/
libname tmj "C:\Users\nwalker\Desktop\reg\";
proc import datafile="C:\Users\nwalker\Desktop\reg\tmj.csv" out=tmj.main dbms=csv replace;
	getnames=yes;
run;

/*Put all formatting here*/
proc format;
	value Gender
		0="No People"
		1="Male"
		2="Female"
		3="Both";
	value Ncategory
		1="Consumer"
		2="Professional (MD,RN)"
		3="Television or Internet Based News";
	value Category
		1="Consumer"
		2="Professional (MD,RN)"
		3="Television Based News"
		4="Internet Based News"
		.="Total";
	value bins
		1="Yes"
		2="No";
	value cure
		1="Yes"
		.="NA"
run;

/************************************************************Week 1 Tasks:**************************************************************/
*1. Create Views_Per_Day variable and produce histogram of Views_Per_Day
*2. Create Numeric Length_of_Video (time) and produce histogram of time
*3. Make all continuous variables from categorical to numeric values and produce histograms for each
*4. For all five continuous variables, find out the mean, median, range, 95%CI of each source level and its corresponding
*   proportion (percentage) among the whole dataset. (See table 1&2 in the manuscript)
*5. Create binary Theme dummy variables
*6. Determine how many meaningful source levels and create new source variable with less categories (say k levels), produce
*   frequencey tables of the initial source variable and the new source variable, check if frequency add up.
*7. Produce 2*K frequency table of each content variables including the binary themes versus new source variable (with k levels)
*   high-light the zero counts. See table 4 in the manuscript. ---We need the column frequency (i.e., column percentage) from
*   frequency table;
/***************************************************************************************************************************************/




/*******Week 1, Task 1********/
*1.1. Create Views_Per_Day variable and produce histogram of Views_Per_Day;

*1.1.a. Create "Date Data Gathered" Variable and "Views per Day" variable;
data tmj.main;
	set tmj.main;
	Gathered=input("01SEP16",date7.); /*new variable for "date of data gathering", set to date7. format*/
		label gathered="September 1, 2016";
	TotalDays=Gathered-Date_of_upload;
		label totaldays="Number of Days Video Has Been Online";
	ViewsPerDay=Number_of_views/TotalDays;
		label viewsperday="Views Per Day";

	label Category="Video Source Category"; /*this is for later*/
run;
ods rtf file="Week11.rtf";
*1.1.b Make Histogram of ViewsPerDay;
proc univariate data=tmj.main noprint;
	histogram ViewsPerDay / normal(noprint);
		title "Task 1: Histogram of Views Per Day";
run;
ods rtf close;


/*******Week 1, Task 2*******/
*2. Create Numeric Length_of_Video (time) and produce histogram of time;
*1.2.a. Convert time into number of minutes;
data tmj.main;
	set tmj.main;
	VideoInMinutes=length_of_video/60;
		label videoinminutes="Video Length (in minutes)";
run;

ods rtf file="Week12.rtf";
*1.2.b. Make Histogram of Video Length in Minutes;
proc univariate data=tmj.main noprint;
	histogram VideoInMinutes / normal(noprint);
		title "Task 2: Make Histogram of Video Length (in minutes)";
run;
ods rtf close;



/********Week 1, Task 3*******/
*3. Make all continuous variables from categorical to numeric values and produce histograms for each;
*1.3.a. Check each variable's formatting --> all continuous variables are already numeric;
ods rtf file="Week13.rtf";
proc contents data=tmj.main varnum;
	title "Task 3(A): Check that continuous variables are already numeric";
run;

*1.3.b. Make Histogram of each continuous variable: Number_of_views_, TotalDays, (VideoInMinutes, viewsPerDay);
proc univariate data=tmj.main noprint;
	histogram TotalDays / normal(noprint);				/*Total number of days video has been online*/
	histogram Number_of_views / normal(noprint); 		/*Total number of views*/
	histogram viewsPerDay / normal(noprint);			/*Views per day - seen above*/
	histogram VideoInMinutes / normal(noprint);			/*Video length in minutes - seen above*/
		title "Task 3(B): Make histogram of remaining continuous variables -- 'Number of Days Video Has Existed' and 'Number of Views'";
run;
ods rtf close;



/**********Week 1, Task 4**********/
*1.4. For all continuous variables, find out the mean, median, range, 95%CI of each source level and its corresponding
*     proportion (percentage) among the whole dataset. (See table 1&2 in the manuscript);

ods rtf file="Week14.rtf";
*1.4.a. Get Mean, Median, Range, and 95% CI by Category for each continuous variable -- ;
proc means data=tmj.main mean median min max clm sum;
	class Category;
	var VideoInMinutes ViewsPerDay number_of_views TotalDays;
		title "Task 4(A): Create table of summary statistics for continuous variables by each Source Category";
	format Category Category.;
	*output out=tmj.cats sum=;
run;

*1.4.b. Get summary statistics for each continuous variable, overall;
proc means data=tmj.main mean median min max clm sum;
	var VideoInMinutes ViewsPerDay number_of_views TotalDays;
		title "Task 4(B): Create table of summary statistics for continuous variables (all Source Categories combined)";
run;

*1.4.c. Get percentage/proportion of counts for each category;
data tmj.cats;
	set tmj.cats;
	by Category;
	VideoInMinutesPct=VideoInMinutes/1001.4166667;
		label videoinminutespct="Percent of Video Length (in minutes)";
	ViewsPerDayPct=ViewsPerDay/3739.7984227;
		label viewsperdaypct="Percent of Views Per Day";
	NumberOfViewsPct=Number_of_views/4749360;
		label numberofviewspct="Percent of Total Number of Views";
	TotalDaysPct=TotalDays/153483;
		label totaldayspct="Percent of Total Days Video Has Been Online";
run;

proc print data=tmj.cats noobs;
	var VideoInMinutesPct ViewsPerDayPct NumberOfViewsPct TotaldaysPct;
	by Category;
	format VideoInMinutesPct PERCENT10.3 ViewsPerDayPct PERCENT10.3 NumberOfViewsPct PERCENT10.3 TotalDaysPct PERCENT10.3;
		title "Task 4(C): Display each Source Category's percentage for each continuous variable";
run;
ods rtf close;


/*********Week 1, Task 5**********/
*1.5. Create binary Theme dummy variables;
*No Themes;

/********Week 1, Task 6**********/
*1.6. Determine how many meaningful source levels and create new source variable with less categories (say k levels), produce
*     frequencey tables of the initial source variable and the new source variable, check if frequency add up;

*1.6.a. Because the above tables showed that Categories for "Television Based News" and "Internet Based News" had just 5 and 4
*       observations, respectively, I will here combine those levels. All other levels were zero, except "Consumer" and "Professional,"
*       which had 62 and 29 observations, respectively;
data tmj.main;
	set tmj.main;
Ncategory=category;
	if Ncategory=4 then Ncategory=3; 
	label Ncategory="New Category";
run;

ods rtf file="Week16.rtf";
*1.6.b. Output frequency tables of Category and Ncategory variables --> Counts do add up;
proc freq data=tmj.main;
	table Category;
	table Ncategory;
	format Category Category. Ncategory Ncategory.;
		title "Task 6: Confirm that the frequencies for the newly combined Source Categories are correct";
run;
ods rtf close;



/*********Week 1, Task 7**********/
*1.7. Produce 2*K frequency table of each content variables including the binary themes versus new source variable (with k levels)
*     high-light the zero counts. See table 4 in the manuscript. ---We need the column frequency (i.e., column percentage) from
*     frequency table;
data tmj.main;
	set tmj.main;
	/*create labels and make things pretty*/
		label gender="Presenter's Gender";
		label what="Explains What TMJ is";
		label how_arthritis="Explains how you get TMJ (Arthritis)";
		label how_grinding="Explains how you get TMJ (Grinding)";
		label how_dislocation="Explains how you get TMJ (Dislocation)";
		label how_injury="Explains how you get TMJ (Injury)";
		label how_alignment="Explains how you get TMJ (Jaw Alignment Issues)";
		label mention_testing="Mentions testing";
		label mention_treat_soft="Mentions treatment: Soft Foods";
		label mention_treatment_gum="Mentions treatment: no gum or nail biting";
		label mention_treatment_heat="Mentions treatment: heat packs";
		label mention_treatment_relax="Mentions treatment: relaxation (includes meditation/biofeedback)";
		label mention_treatment_guard="Mentions treatment:  mouth guard";
		label mention_treatment_meds="Mentions treatment: pain medication";
		label mention_treatment_exercise="Mentions treatment: exercise";
		label mention_prevention="Mentions Prevention";
		label mention_surgery="Mentions Surgery";
		label mention_pain="Mentions Pain";
		label personal_experience="Highlights a persons personal experience";
		label product="Is selling products";
		label product_cure="If seeling product, is supposed to cure or curb TMJ";
run;
ods rtf file="week17.rtf";
proc freq data=tmj.main;
	tables (gender what how_arthritis how_grinding how_dislocation how_injury how_alignment 
			mention_testing mention_treat_soft mention_treatment_gum mention_treatment_heat
			mention_treatment_relax mention_treatment_guard mention_treatment_meds
			mention_treatment_exercise mention_prevention mention_surgery mention_pain
			personal_experience product product_cure)*Ncategory / norow nopercent;
	format 
		Ncategory Ncategory. 
		gender Gender. 
		What bins.
		how_arthritis bins.
		How_Grinding bins.
		How_Dislocation bins.
		how_injury bins.
		how_alignment bins.
		mention_testing bins.
		mention_treat_soft bins.
		mention_treatment_gum bins.
		mention_treatment_heat bins.
		mention_treatment_relax bins.
		mention_treatment_guard bins.
		mention_treatment_meds bins.
		mention_treatment_exercise bins.
		mention_prevention bins.
		mention_surgery bins.
		mention_pain bins.
		personal_experience bins.
		product bins.
		product_cure cure.
	;
		title "Task 7: Produce 2*K frequency tables of each content variable by Source Category";
run;
ods rtf close;

/********Week 1 Fixes!***********/
*1. Get SE and UCL for all four continuous variables;
proc means data=tmj.main mean median min max clm stderr sum;
	class Category;
	var VideoInMinutes ViewsPerDay number_of_views TotalDays;
	format Category Category.;
run;

*2. Get SE and UCL for overall for continuous variables;
proc means data=tmj.main mean median min max clm stderr sum;
	var VideoInMinutes ViewsPerDay number_of_views TotalDays;
run;

/************************************************************Week 2 Tasks:**************************************************************/
*1. Create Table 3 in the manuscript by Kruskal-Wallis H test for all five continuous variables.
*2. Create a new table with the correlation matrx (5-by-5) for all five continuous variables with Spearman's rho and p-value.
*3. Create Table 5 in the manuscript by simple logistic regression.
*4. Finish IRR analysis for the second data set.;
/***************************************************************************************************************************************/

/*********Week 2, Task 1**********/
*Create Table 3 in the manuscript by Kruskal-Wallis H test for all five continuous variables;

proc npar1way data=tmj.main;
	class Ncategory;
	var TotalDays Number_of_Views viewsperday videoinminutes;
run;

/*********Week 2, Task 2**********/
*Create a new table with the correlation matrx (5-by-5) for all five continuous variables with Spearman's rho and p-value;

proc corr data=tmj.main spearman;
	var TotalDays Number_of_Views ViewsPerDay VideoInMinutes;
run;


/*********Week 2, Task 3**********/
*Create Table 5 in the manuscript by simple logistic regression;
/* Create binary gender variables;*/
data tmj.main;
	set tmj.main;
	if Gender = 0 then Gender_Neither = 1; else Gender_Neither = 2;
	if Gender = 1 then Gender_Male = 1; else Gender_Male = 2;
	if Gender = 2 then Gender_Female = 1; else Gender_Female = 2;
	if Gender = 3 then Gender_Both = 1; else Gender_Both = 2;
run;

/*Run Proc Logistic*/
proc logistic data=tmj.main;
	class Ncategory (ref="1" param=ref);
	model Gender = Ncategory / link=glogit;
run;	

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model Gender_neither = Ncategory;
run;	

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model Gender_male = Ncategory;
run;	

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model Gender_female = Ncategory;
run;	

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model Gender_both = Ncategory;
run;	

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model What = Ncategory;
run;	

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model how_arthritis = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model How_Grinding = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model How_Dislocation = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model how_injury = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model how_alignment = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model mention_testing = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model mention_treat_soft = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model mention_treatment_heat = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model mention_treatment_gum = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model mention_treatment_relax = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model mention_treatment_guard = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model mention_treatment_meds = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model mention_treatment_exercise = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model mention_treatment_exercise = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model mention_prevention = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model mention_surgery = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model mention_pain = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model personal_experience = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	model product = Ncategory;
run;

proc logistic data=tmj.main;
*not using "descending" because 1=Yes and 2=No;
	class Ncategory (ref="1" param=ref);
	where product = 1;
	model product_cure = Ncategory;
run;

/*********Week 2, Task 4**********/
*Finish IRR analysis for the second data set.;
*Raw Data Changes
*1. Replaced all commas with periods (no numbers affected).
*2. Replaced all variable names with simpler ones.
*3. Removed strange, floating data in lines 2 and 3 from
*   columns AM to BL.
*4. Saved as CSV.;

/*Data import*/
proc import datafile="C:\Users\nwalker\Desktop\reg\tmjirr.csv" out=tmj.irr dbms=csv replace;
	getnames=yes;
run;

/*Check data and var types*/
proc contents data=tmj.irr;
run;

proc sort data=tmj.irr;
	by url;
run;

/*Create separate datasets by rater, change length to time in minutes, then change var names */
data tmj.irrAD;
	set tmj.irr;
	by url;
if Coder="CB" then delete;
length_mins=length_of_video/60;
run;
data tmj.irrCB;
	set tmj.irr;
	by url;
if Coder="AD" then delete;
cure2 = cure;
gender2=gender;
How_Alignment2 = How_alignment;
how_arthritis2 = how_arthritis;
how_dislocation2 = how_dislocation;
how_grinding2 = how_grinding;
how_injury2 = how_injury;
mention_gum2=mention_gum;
mention_pain2=mention_pain;
mention_prevention2=mention_prevention;
mention_soft2=mention_soft;
mention_surgery2=mention_surgery;
mention_testing2=mention_testing;
personal2=personal;
products2=products;
professional2=professional;
source2=source;
Treatment_exercise2=treatment_exercise;
treatment_guard2=treatment_guard;
treatment_heat2=treatment_heat;
treatment_meds2=treatment_meds;
treatment_relax2=treatment_relax;
what2=what;
name_of_video2=name_of_video;
length_mins2=length_of_video/60;
run;
/*get rid of the old variables and Coder var*/
data tmj.irrCB(drop=cure gender how_alignment how_arthritis how_dislocation how_grinding how_injury length_of_video
	mention_gum mention_prevention mention_soft mention_surgery mention_testing name_of_video personal products professional source
	treatment_exercise treatment_guard treatment_meds treatment_relax what coder treatment_heat mention_pain);
	set tmj.irrcb;
run;
data tmj.irrAD(drop=coder length_of_video);
	set tmj.irrad;
run;

/*Combine data sets in matched pairs*/
data tmj.irrfull;
	merge tmj.irrAD tmj.irrCB;
	by url;
run;

/*Kappa statistics*/
proc freq data=tmj.irrfull;
	tables 
		cure*cure2 gender*gender2 how_alignment*how_alignment2 how_arthritis*how_arthritis2 how_dislocation*how_dislocation2
		how_grinding*how_grinding2 how_injury*how_injury2 length_mins*length_mins2 mention_gum*mention_gum2
		mention_soft*mention_soft2 mention_surgery*mention_surgery2 mention_testing*mention_testing2 name_of_video*name_of_video2
		personal*personal2 products*products2 professional*professional2 source*source2 treatment_exercise*treatment_exercise2
		treatment_guard*treatment_guard2 treatment_heat*treatment_heat2 treatment_meds*treatment_meds2 treatment_relax*treatment_relax2
		what*what2 / agree;
	test kappa;
run;

proc contents data=tmj.irrfull;
run;


