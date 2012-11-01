@echo off

SET p0=C:\ampC
SET p1=%p0%\A_LightScreen_Capture
SET p2=%p0%\A_Soft
SET p3=%p0%\A_ToDelete
SET p4=%p0%\A_VM
SET p5=%p0%\B_A_Repository

FOR %%p IN ( %p0% %p1% %p2% %p3% %p4% %p5% ) DO ( 
	IF EXIST %%p ( 
		echo Skip creating %%p, as already exist
	) ELSE ( 
		echo Creating %%p
		mkdir %%p
	) 
)

PAUSE
