<?php
	session_start();
	if($_SESSION["languageid"])
		$grs_app_lang = $_SESSION["languageid"];
	else
	{
		$grs_app_lang = 1;
		$_SESSION["languageid"] = $grs_app_lang;
	}
	$grs_db_name	 = getenv('MYSQL_DATABASE');
	$grs_db_host	 = getenv('MYSQL_HOST');
	$grs_db_username = getenv('MYSQL_USER');
	$grs_db_password = getenv('MYSQL_PASSWORD');
	$app_useraccess  = 1;
	$grs_debugmode  = 0;			// DebugMode
	$grs_debuginfo  = array();		// Debuginfo
?>
