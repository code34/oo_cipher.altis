	/*
	Author: code34 nicolas_boiteux@yahoo.fr
	Copyright (C) 2017-2018 Nicolas BOITEUX

	CLASS OO_CRYPT RC4
	
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

		PUBLIC FUNCTION("array","Utf8ToBin") {
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

		PUBLIC FUNCTION("array","BinToUtf8") {
			private _decimal = 0;
			private _strings = [];
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
				_strings pushBack _decimal;
			};
			_strings;
		};

		PUBLIC FUNCTION("array","KeySchedule") {
			private _key = _this;
			private _len = count _key;
			private _array = [];
			private _j = 0;
			private _permute = 0;

			for "_i" from 0 to 255 step 1 do { _array set [_i, _i]; };
			for "_i" from 0 to 255 step 1 do {
				_permute = (_array select _i);
				_j = (_j + _permute + (_key select (_i mod _len))) mod 256;
				_array set [_i, (_array select _j)];
				_array set [_j, _permute];
			};
			_array;
		};

		PUBLIC FUNCTION("array","crypt") {
			private _i = 0;
			private _j = 0;
			private _key = MEMBER("KeySchedule", toArray (_this select 0));
			private _data = toArray (_this select 1);
			private _permute = 0;
			private _cypherstream = [];
			private _cypherdata = [];

			{
				_i = (_i + 1) mod 256;
				_j = (_j + (_key select _i)) mod 256;
				_permute = (_key select _i);
				_key set [_i, (_key select _j)];
				_key set [_j, _permute];
				_cypherstream pushBack (((_key select _i) + (_key select _j)) mod 256);
				true;
			} count _data;

			_data = MEMBER("Utf8ToBin", _data);	
			{
				_cypherdata pushBack ((_x || _data select _forEachIndex) && !(_x && _data select _forEachIndex));
			} forEach MEMBER("Utf8ToBin", _cypherstream);
			toString(MEMBER("BinToUtf8", _cypherdata));
		};

		PUBLIC FUNCTION("","deconstructor") { 

		};
	ENDCLASS;