***DO FIRST 

	* Clean 
		global cleanAfAc "C:/Data/IeDEA/SH/AfAc/v2.2/clean"
		global cleanAfA "C:/Data/IeDEA/SH/AfA/v6.0/clean"
		
	* Source
		global sourceAfAc "C:/Data/IeDEA/SH/AfAc/v2.2/source"
		global sourceAfA "C:/Data/IeDEA/SH/AfA/v6.0/source"
			
	* Generate data folder & sub-folders
		capture mkdir "C:/Data/IeDEA/SH/Combined"
		capture mkdir "C:/Data/IeDEA/SH/Combined/v1.0"
		capture mkdir "C:/Data/IeDEA/SH/Combined/v1.0/clean"		
		
	* Clean 
		global clean "C:/Data/IeDEA/SH/Combined/v1.0/clean"
		global temp "C:/Data/IeDEA/SH/Combined/v1.0/temp"
		global source "C:/Data/IeDEA/SH/Combined/v1.0/source"

	* Ado files path 
		sysdir set PERSONAL "C:/Repositories/ado"		
		
	* GitHub repository path 
		global repo "C:/Repositories/SH"
		
	* Generate repository sub-folders & define macros with file paths 
		foreach f in docs figures tables concept {
			capture mkdir "$repo/`f'"
			global `f' "$repo/`f'"
		}