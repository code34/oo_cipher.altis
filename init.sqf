	call compilefinal preprocessFileLineNumbers "oo_crypt.sqf";

	sleep 2;

	_crypt = "new" call OO_CRYPT;
	_key = ["crypt",["mypassphrasetogeneratekey", "tout mon texte que je vais chiffrer et déchiffrer :)"]] call _crypt;
	_key = ["crypt",["mypassphrasetogeneratekey", _key]] call _crypt;

	hintc format ["%1", _key];



