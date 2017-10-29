﻿	/*
	Author: code34 nicolas_boiteux@yahoo.fr
	Copyright (C) 2017-2018 Nicolas BOITEUX

	CLASS OO_CRYPT - Rivest Cipher 4
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>. 
	*/

	#include "oop.h"

	CLASS("OO_CRYPT")
		PUBLIC FUNCTION("","constructor") {	

		};

		PUBLIC FUNCTION("array","DecToBin") {
			private _binary = [];
			private _decimal = 0;
			private _bool = false;
			private _power = 0;

			{
				if (_x > 255) then {_decimal = 0;} else {_decimal = _x;};
				for "_i" from 7 to 0 step -1 do {
					_power = 2^(_i);
					_bool = (_power <= _decimal);
					_binary pushBack _bool;
					if (_bool) then {_decimal = _decimal - _power};
				};
			} count _this;
			_binary;
		};

		PUBLIC FUNCTION("array","BinToDec") {
			private _decimal = 0;
			private _decimals = [];
			private _bool = false;
			private _power = 0;

			while { count _this > 0} do {
				_decimal = 0;
				for "_i" from 7 to 0 step -1 do {
					_bool = _this deleteat 0;
					_power = 2^(_i);
					if(_bool) then {_decimal = _decimal + _power; };
				};
				if(_decimal isEqualTo 0) then { _decimal = 256;};
				_decimals pushBack _decimal;
			};
			_decimals;
		};

		PUBLIC FUNCTION("array","DecToHexa") {
			private _hexa = "0123456789ABCDEF";
			private _strings = "";

			{
				if(_x isEqualTo 256) then {_x = 0;};
				{
					_strings = _strings + (_hexa select [_x,1]);
				}foreach [floor (_x / 16), (_x mod 16)];
			} forEach _this;
			_strings;
		};

		PUBLIC FUNCTION("string","StrToHexa") {
			MEMBER("DecToHexa", toArray (_this));
		};


		PUBLIC FUNCTION("string","HexaToDec") {
			private _hexa = toArray "0123456789ABCDEF";
			private _array = toArray _this;
			private _decimals = [];
			private _decimal = 0;

			while { count _array > 0 } do {
				_decimal = (_hexa find (_array select 0)) * 16 + (_hexa find (_array select 1));
				if(_decimal isEqualTo 0) then {_decimal = 256;};
				_decimals pushBack _decimal;
				_array deleteRange [0,2];
			};
			_decimals;
		};

		PUBLIC FUNCTION("array","KeySchedule") {
			private _key = _this;
			private _keylen = 256;
			private _array = [];
			private _j = 0;
			private _permute = 0;
			private _index1 = 0;
			private _index2 = 0;

			while { count _key < _keylen} do { _key pushBack 1; };

			for "_i" from 0 to 255 step 1 do { _array set [_i, _i]; };
			for "_i" from 0 to 255 step 1 do {
				_permute = (_array select _i);
				_j = (_j + _permute + (_key select (_i mod _keylen))) mod 256;
				_array set [_i, (_array select _j)];
				_array set [_j, _permute];
			};
			_array;
		};

		PUBLIC FUNCTION("array","crypt") {
			if!((_this select 0) isEqualType "") exitWith { hintC "OO_CRYPT::error: key must be a string"; "";};
			private _data = [];
			if((_this select 1) isEqualType "") then { _data = toArray (_this select 1); } else { _data = _this select 1;};
			private _i = 0;
			private _j = 0;
			private _key = MEMBER("KeySchedule", toArray (_this select 0));
			private _permute = 0;
			private _keystream = [];
			private _cipherdata = [];

			{
				_i = (_i + 1) mod 256; // 1
				_j = (_j + (_key select _i)) mod 256; // 32
				_permute = (_key select _i);
				_key set [_i, (_key select _j)];
				_key set [_j, _permute];
				_keystream pushBack (((_key select _i) + (_key select _j)) mod 256);
				true;
			} count _data;

			_data = MEMBER("DecToBin", _data);	
			{
				_cipherdata pushBack ((_x || _data select _forEachIndex) && !(_x && _data select _forEachIndex));
			} forEach MEMBER("DecToBin", _keystream);
			MEMBER("BinToDec", _cipherdata);
		};

		PUBLIC FUNCTION("","deconstructor") { 

		};
	ENDCLASS;