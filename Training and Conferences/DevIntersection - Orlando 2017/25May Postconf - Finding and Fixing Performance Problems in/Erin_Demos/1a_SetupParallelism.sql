/*============================================================================
  File:     1a_SetupParallelism.sql

  Summary:  Create some parallelism waits

  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

  (c) 2011, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- If the ParallelismTest database does not exist,consider
-- restoring it from the backup instead.
/*
RESTORE DATABASE [ParallelismTest] FROM
DISK = N'D:\SQLskills\DemoBackups\Parallelism.bak'
WITH REPLACE;
GO

BACKUP DATABASE [ParallelismTest] TO
DISK = N'D:\SQLskills\DemoBackups\Parallelism.bak'
WITH INIT;
GO
*/


-- Create two tables to store data, one sparse and one not.
USE [master];
GO

IF DATABASEPROPERTYEX (N'ParallelismTest', N'Version') > 0
BEGIN
	ALTER DATABASE [ParallelismTest] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [ParallelismTest];
END
GO

CREATE DATABASE [ParallelismTest];
GO

USE [ParallelismTest];
GO
SET NOCOUNT ON;
GO

CREATE TABLE [NonSparseDocRepository] (
	[DocID] INT IDENTITY, [DocName] VARCHAR (100), [DocType] INT,
	[c4] INT NULL, [c5] INT NULL, [c6] INT NULL, [c7] INT NULL, [c8] INT NULL, [c9] INT NULL,	[c10] INT NULL, [c11] INT NULL, [c12] INT NULL, [c13] INT NULL, [c14] INT NULL, [c15] INT NULL, [c16] INT NULL, [c17] INT NULL, [c18] INT NULL, [c19] INT NULL,	[c20] INT NULL, [c21] INT NULL, [c22] INT NULL, [c23] INT NULL, [c24] INT NULL, [c25] INT NULL, [c26] INT NULL, [c27] INT NULL, [c28] INT NULL, [c29] INT NULL,	[c30] INT NULL, [c31] INT NULL, [c32] INT NULL, [c33] INT NULL, [c34] INT NULL, [c35] INT NULL, [c36] INT NULL, [c37] INT NULL, [c38] INT NULL, [c39] INT NULL,	[c40] INT NULL, [c41] INT NULL, [c42] INT NULL, [c43] INT NULL, [c44] INT NULL, [c45] INT NULL, [c46] INT NULL, [c47] INT NULL, [c48] INT NULL, [c49] INT NULL,	[c50] INT NULL, [c51] INT NULL, [c52] INT NULL, [c53] INT NULL, [c54] INT NULL, [c55] INT NULL, [c56] INT NULL, [c57] INT NULL, [c58] INT NULL, [c59] INT NULL,	[c60] INT NULL, [c61] INT NULL, [c62] INT NULL, [c63] INT NULL, [c64] INT NULL, [c65] INT NULL, [c66] INT NULL, [c67] INT NULL, [c68] INT NULL, [c69] INT NULL,	[c70] INT NULL, [c71] INT NULL, [c72] INT NULL, [c73] INT NULL, [c74] INT NULL, [c75] INT NULL, [c76] INT NULL, [c77] INT NULL, [c78] INT NULL, [c79] INT NULL,	[c80] INT NULL, [c81] INT NULL, [c82] INT NULL, [c83] INT NULL, [c84] INT NULL, [c85] INT NULL, [c86] INT NULL, [c87] INT NULL, [c88] INT NULL, [c89] INT NULL,	[c90] INT NULL, [c91] INT NULL, [c92] INT NULL, [c93] INT NULL, [c94] INT NULL, [c95] INT NULL, [c96] INT NULL, [c97] INT NULL, [c98] INT NULL, [c99] INT NULL,
	[c100] INT NULL, [c101] INT NULL, [c102] INT NULL, [c103] INT NULL, [c104] INT NULL, [c105] INT NULL, [c106] INT NULL, [c107] INT NULL, [c108] INT NULL, [c109] INT NULL,	[c110] INT NULL, [c111] INT NULL, [c112] INT NULL, [c113] INT NULL, [c114] INT NULL, [c115] INT NULL, [c116] INT NULL, [c117] INT NULL, [c118] INT NULL, [c119] INT NULL,	[c120] INT NULL, [c121] INT NULL, [c122] INT NULL, [c123] INT NULL, [c124] INT NULL, [c125] INT NULL, [c126] INT NULL, [c127] INT NULL, [c128] INT NULL, [c129] INT NULL,	[c130] INT NULL, [c131] INT NULL, [c132] INT NULL, [c133] INT NULL, [c134] INT NULL, [c135] INT NULL, [c136] INT NULL, [c137] INT NULL, [c138] INT NULL, [c139] INT NULL,	[c140] INT NULL, [c141] INT NULL, [c142] INT NULL, [c143] INT NULL, [c144] INT NULL, [c145] INT NULL, [c146] INT NULL, [c147] INT NULL, [c148] INT NULL, [c149] INT NULL,	[c150] INT NULL, [c151] INT NULL, [c152] INT NULL, [c153] INT NULL, [c154] INT NULL, [c155] INT NULL, [c156] INT NULL, [c157] INT NULL, [c158] INT NULL, [c159] INT NULL,	[c160] INT NULL, [c161] INT NULL, [c162] INT NULL, [c163] INT NULL, [c164] INT NULL, [c165] INT NULL, [c166] INT NULL, [c167] INT NULL, [c168] INT NULL, [c169] INT NULL,	[c170] INT NULL, [c171] INT NULL, [c172] INT NULL, [c173] INT NULL, [c174] INT NULL, [c175] INT NULL, [c176] INT NULL, [c177] INT NULL, [c178] INT NULL, [c179] INT NULL,	[c180] INT NULL, [c181] INT NULL, [c182] INT NULL, [c183] INT NULL, [c184] INT NULL, [c185] INT NULL, [c186] INT NULL, [c187] INT NULL, [c188] INT NULL, [c189] INT NULL,	[c190] INT NULL, [c191] INT NULL, [c192] INT NULL, [c193] INT NULL, [c194] INT NULL, [c195] INT NULL, [c196] INT NULL, [c197] INT NULL, [c198] INT NULL, [c199] INT NULL,
	[c200] INT NULL, [c201] INT NULL, [c202] INT NULL, [c203] INT NULL, [c204] INT NULL, [c205] INT NULL, [c206] INT NULL, [c207] INT NULL, [c208] INT NULL, [c209] INT NULL,	[c210] INT NULL, [c211] INT NULL, [c212] INT NULL, [c213] INT NULL, [c214] INT NULL, [c215] INT NULL, [c216] INT NULL, [c217] INT NULL, [c218] INT NULL, [c219] INT NULL,	[c220] INT NULL, [c221] INT NULL, [c222] INT NULL, [c223] INT NULL, [c224] INT NULL, [c225] INT NULL, [c226] INT NULL, [c227] INT NULL, [c228] INT NULL, [c229] INT NULL,	[c230] INT NULL, [c231] INT NULL, [c232] INT NULL, [c233] INT NULL, [c234] INT NULL, [c235] INT NULL, [c236] INT NULL, [c237] INT NULL, [c238] INT NULL, [c239] INT NULL,	[c240] INT NULL, [c241] INT NULL, [c242] INT NULL, [c243] INT NULL, [c244] INT NULL, [c245] INT NULL, [c246] INT NULL, [c247] INT NULL, [c248] INT NULL, [c249] INT NULL,	[c250] INT NULL, [c251] INT NULL, [c252] INT NULL, [c253] INT NULL, [c254] INT NULL, [c255] INT NULL, [c256] INT NULL, [c257] INT NULL, [c258] INT NULL, [c259] INT NULL,	[c260] INT NULL, [c261] INT NULL, [c262] INT NULL, [c263] INT NULL, [c264] INT NULL, [c265] INT NULL, [c266] INT NULL, [c267] INT NULL, [c268] INT NULL, [c269] INT NULL,	[c270] INT NULL, [c271] INT NULL, [c272] INT NULL, [c273] INT NULL, [c274] INT NULL, [c275] INT NULL, [c276] INT NULL, [c277] INT NULL, [c278] INT NULL, [c279] INT NULL,	[c280] INT NULL, [c281] INT NULL, [c282] INT NULL, [c283] INT NULL, [c284] INT NULL, [c285] INT NULL, [c286] INT NULL, [c287] INT NULL, [c288] INT NULL, [c289] INT NULL,	[c290] INT NULL, [c291] INT NULL, [c292] INT NULL, [c293] INT NULL, [c294] INT NULL, [c295] INT NULL, [c296] INT NULL, [c297] INT NULL, [c298] INT NULL, [c299] INT NULL,
	[c300] INT NULL, [c301] INT NULL, [c302] INT NULL, [c303] INT NULL, [c304] INT NULL, [c305] INT NULL, [c306] INT NULL, [c307] INT NULL, [c308] INT NULL, [c309] INT NULL,	[c310] INT NULL, [c311] INT NULL, [c312] INT NULL, [c313] INT NULL, [c314] INT NULL, [c315] INT NULL, [c316] INT NULL, [c317] INT NULL, [c318] INT NULL, [c319] INT NULL,	[c320] INT NULL, [c321] INT NULL, [c322] INT NULL, [c323] INT NULL, [c324] INT NULL, [c325] INT NULL, [c326] INT NULL, [c327] INT NULL, [c328] INT NULL, [c329] INT NULL,	[c330] INT NULL, [c331] INT NULL, [c332] INT NULL, [c333] INT NULL, [c334] INT NULL, [c335] INT NULL, [c336] INT NULL, [c337] INT NULL, [c338] INT NULL, [c339] INT NULL,	[c340] INT NULL, [c341] INT NULL, [c342] INT NULL, [c343] INT NULL, [c344] INT NULL, [c345] INT NULL, [c346] INT NULL, [c347] INT NULL, [c348] INT NULL, [c349] INT NULL,	[c350] INT NULL, [c351] INT NULL, [c352] INT NULL, [c353] INT NULL, [c354] INT NULL, [c355] INT NULL, [c356] INT NULL, [c357] INT NULL, [c358] INT NULL, [c359] INT NULL,	[c360] INT NULL, [c361] INT NULL, [c362] INT NULL, [c363] INT NULL, [c364] INT NULL, [c365] INT NULL, [c366] INT NULL, [c367] INT NULL, [c368] INT NULL, [c369] INT NULL,	[c370] INT NULL, [c371] INT NULL, [c372] INT NULL, [c373] INT NULL, [c374] INT NULL, [c375] INT NULL, [c376] INT NULL, [c377] INT NULL, [c378] INT NULL, [c379] INT NULL,	[c380] INT NULL, [c381] INT NULL, [c382] INT NULL, [c383] INT NULL, [c384] INT NULL, [c385] INT NULL, [c386] INT NULL, [c387] INT NULL, [c388] INT NULL, [c389] INT NULL,	[c390] INT NULL, [c391] INT NULL, [c392] INT NULL, [c393] INT NULL, [c394] INT NULL, [c395] INT NULL, [c396] INT NULL, [c397] INT NULL, [c398] INT NULL, [c399] INT NULL,
	[c400] INT NULL, [c401] INT NULL, [c402] INT NULL, [c403] INT NULL, [c404] INT NULL, [c405] INT NULL, [c406] INT NULL, [c407] INT NULL, [c408] INT NULL, [c409] INT NULL,	[c410] INT NULL, [c411] INT NULL, [c412] INT NULL, [c413] INT NULL, [c414] INT NULL, [c415] INT NULL, [c416] INT NULL, [c417] INT NULL, [c418] INT NULL, [c419] INT NULL,	[c420] INT NULL, [c421] INT NULL, [c422] INT NULL, [c423] INT NULL, [c424] INT NULL, [c425] INT NULL, [c426] INT NULL, [c427] INT NULL, [c428] INT NULL, [c429] INT NULL,	[c430] INT NULL, [c431] INT NULL, [c432] INT NULL, [c433] INT NULL, [c434] INT NULL, [c435] INT NULL, [c436] INT NULL, [c437] INT NULL, [c438] INT NULL, [c439] INT NULL,	[c440] INT NULL, [c441] INT NULL, [c442] INT NULL, [c443] INT NULL, [c444] INT NULL, [c445] INT NULL, [c446] INT NULL, [c447] INT NULL, [c448] INT NULL, [c449] INT NULL,	[c450] INT NULL, [c451] INT NULL, [c452] INT NULL, [c453] INT NULL, [c454] INT NULL, [c455] INT NULL, [c456] INT NULL, [c457] INT NULL, [c458] INT NULL, [c459] INT NULL,	[c460] INT NULL, [c461] INT NULL, [c462] INT NULL, [c463] INT NULL, [c464] INT NULL, [c465] INT NULL, [c466] INT NULL, [c467] INT NULL, [c468] INT NULL, [c469] INT NULL,	[c470] INT NULL, [c471] INT NULL, [c472] INT NULL, [c473] INT NULL, [c474] INT NULL, [c475] INT NULL, [c476] INT NULL, [c477] INT NULL, [c478] INT NULL, [c479] INT NULL,	[c480] INT NULL, [c481] INT NULL, [c482] INT NULL, [c483] INT NULL, [c484] INT NULL, [c485] INT NULL, [c486] INT NULL, [c487] INT NULL, [c488] INT NULL, [c489] INT NULL,	[c490] INT NULL, [c491] INT NULL, [c492] INT NULL, [c493] INT NULL, [c494] INT NULL, [c495] INT NULL, [c496] INT NULL, [c497] INT NULL, [c498] INT NULL, [c499] INT NULL,
	[c500] INT NULL, [c501] INT NULL, [c502] INT NULL, [c503] INT NULL, [c504] INT NULL, [c505] INT NULL, [c506] INT NULL, [c507] INT NULL, [c508] INT NULL, [c509] INT NULL,	[c510] INT NULL, [c511] INT NULL, [c512] INT NULL, [c513] INT NULL, [c514] INT NULL, [c515] INT NULL, [c516] INT NULL, [c517] INT NULL, [c518] INT NULL, [c519] INT NULL,	[c520] INT NULL, [c521] INT NULL, [c522] INT NULL, [c523] INT NULL, [c524] INT NULL, [c525] INT NULL, [c526] INT NULL, [c527] INT NULL, [c528] INT NULL, [c529] INT NULL,	[c530] INT NULL, [c531] INT NULL, [c532] INT NULL, [c533] INT NULL, [c534] INT NULL, [c535] INT NULL, [c536] INT NULL, [c537] INT NULL, [c538] INT NULL, [c539] INT NULL,	[c540] INT NULL, [c541] INT NULL, [c542] INT NULL, [c543] INT NULL, [c544] INT NULL, [c545] INT NULL, [c546] INT NULL, [c547] INT NULL, [c548] INT NULL, [c549] INT NULL,	[c550] INT NULL, [c551] INT NULL, [c552] INT NULL, [c553] INT NULL, [c554] INT NULL, [c555] INT NULL, [c556] INT NULL, [c557] INT NULL, [c558] INT NULL, [c559] INT NULL,	[c560] INT NULL, [c561] INT NULL, [c562] INT NULL, [c563] INT NULL, [c564] INT NULL, [c565] INT NULL, [c566] INT NULL, [c567] INT NULL, [c568] INT NULL, [c569] INT NULL,	[c570] INT NULL, [c571] INT NULL, [c572] INT NULL, [c573] INT NULL, [c574] INT NULL, [c575] INT NULL, [c576] INT NULL, [c577] INT NULL, [c578] INT NULL, [c579] INT NULL,	[c580] INT NULL, [c581] INT NULL, [c582] INT NULL, [c583] INT NULL, [c584] INT NULL, [c585] INT NULL, [c586] INT NULL, [c587] INT NULL, [c588] INT NULL, [c589] INT NULL,	[c590] INT NULL, [c591] INT NULL, [c592] INT NULL, [c593] INT NULL, [c594] INT NULL, [c595] INT NULL, [c596] INT NULL, [c597] INT NULL, [c598] INT NULL, [c599] INT NULL,
	[c600] INT NULL, [c601] INT NULL, [c602] INT NULL, [c603] INT NULL, [c604] INT NULL, [c605] INT NULL, [c606] INT NULL, [c607] INT NULL, [c608] INT NULL, [c609] INT NULL,	[c610] INT NULL, [c611] INT NULL, [c612] INT NULL, [c613] INT NULL, [c614] INT NULL, [c615] INT NULL, [c616] INT NULL, [c617] INT NULL, [c618] INT NULL, [c619] INT NULL,	[c620] INT NULL, [c621] INT NULL, [c622] INT NULL, [c623] INT NULL, [c624] INT NULL, [c625] INT NULL, [c626] INT NULL, [c627] INT NULL, [c628] INT NULL, [c629] INT NULL,	[c630] INT NULL, [c631] INT NULL, [c632] INT NULL, [c633] INT NULL, [c634] INT NULL, [c635] INT NULL, [c636] INT NULL, [c637] INT NULL, [c638] INT NULL, [c639] INT NULL,	[c640] INT NULL, [c641] INT NULL, [c642] INT NULL, [c643] INT NULL, [c644] INT NULL, [c645] INT NULL, [c646] INT NULL, [c647] INT NULL, [c648] INT NULL, [c649] INT NULL,	[c650] INT NULL, [c651] INT NULL, [c652] INT NULL, [c653] INT NULL, [c654] INT NULL, [c655] INT NULL, [c656] INT NULL, [c657] INT NULL, [c658] INT NULL, [c659] INT NULL,	[c660] INT NULL, [c661] INT NULL, [c662] INT NULL, [c663] INT NULL, [c664] INT NULL, [c665] INT NULL, [c666] INT NULL, [c667] INT NULL, [c668] INT NULL, [c669] INT NULL,	[c670] INT NULL, [c671] INT NULL, [c672] INT NULL, [c673] INT NULL, [c674] INT NULL, [c675] INT NULL, [c676] INT NULL, [c677] INT NULL, [c678] INT NULL, [c679] INT NULL,	[c680] INT NULL, [c681] INT NULL, [c682] INT NULL, [c683] INT NULL, [c684] INT NULL, [c685] INT NULL, [c686] INT NULL, [c687] INT NULL, [c688] INT NULL, [c689] INT NULL,	[c690] INT NULL, [c691] INT NULL, [c692] INT NULL, [c693] INT NULL, [c694] INT NULL, [c695] INT NULL, [c696] INT NULL, [c697] INT NULL, [c698] INT NULL, [c699] INT NULL,
	[c700] INT NULL, [c701] INT NULL, [c702] INT NULL, [c703] INT NULL, [c704] INT NULL, [c705] INT NULL, [c706] INT NULL, [c707] INT NULL, [c708] INT NULL, [c709] INT NULL,	[c710] INT NULL, [c711] INT NULL, [c712] INT NULL, [c713] INT NULL, [c714] INT NULL, [c715] INT NULL, [c716] INT NULL, [c717] INT NULL, [c718] INT NULL, [c719] INT NULL,	[c720] INT NULL, [c721] INT NULL, [c722] INT NULL, [c723] INT NULL, [c724] INT NULL, [c725] INT NULL, [c726] INT NULL, [c727] INT NULL, [c728] INT NULL, [c729] INT NULL,	[c730] INT NULL, [c731] INT NULL, [c732] INT NULL, [c733] INT NULL, [c734] INT NULL, [c735] INT NULL, [c736] INT NULL, [c737] INT NULL, [c738] INT NULL, [c739] INT NULL,	[c740] INT NULL, [c741] INT NULL, [c742] INT NULL, [c743] INT NULL, [c744] INT NULL, [c745] INT NULL, [c746] INT NULL, [c747] INT NULL, [c748] INT NULL, [c749] INT NULL,	[c750] INT NULL, [c751] INT NULL, [c752] INT NULL, [c753] INT NULL, [c754] INT NULL, [c755] INT NULL, [c756] INT NULL, [c757] INT NULL, [c758] INT NULL, [c759] INT NULL,	[c760] INT NULL, [c761] INT NULL, [c762] INT NULL, [c763] INT NULL, [c764] INT NULL, [c765] INT NULL, [c766] INT NULL, [c767] INT NULL, [c768] INT NULL, [c769] INT NULL,	[c770] INT NULL, [c771] INT NULL, [c772] INT NULL, [c773] INT NULL, [c774] INT NULL, [c775] INT NULL, [c776] INT NULL, [c777] INT NULL, [c778] INT NULL, [c779] INT NULL,	[c780] INT NULL, [c781] INT NULL, [c782] INT NULL, [c783] INT NULL, [c784] INT NULL, [c785] INT NULL, [c786] INT NULL, [c787] INT NULL, [c788] INT NULL, [c789] INT NULL,	[c790] INT NULL, [c791] INT NULL, [c792] INT NULL, [c793] INT NULL, [c794] INT NULL, [c795] INT NULL, [c796] INT NULL, [c797] INT NULL, [c798] INT NULL, [c799] INT NULL,
	[c800] INT NULL, [c801] INT NULL, [c802] INT NULL, [c803] INT NULL, [c804] INT NULL, [c805] INT NULL, [c806] INT NULL, [c807] INT NULL, [c808] INT NULL, [c809] INT NULL,	[c810] INT NULL, [c811] INT NULL, [c812] INT NULL, [c813] INT NULL, [c814] INT NULL, [c815] INT NULL, [c816] INT NULL, [c817] INT NULL, [c818] INT NULL, [c819] INT NULL,	[c820] INT NULL, [c821] INT NULL, [c822] INT NULL, [c823] INT NULL, [c824] INT NULL, [c825] INT NULL, [c826] INT NULL, [c827] INT NULL, [c828] INT NULL, [c829] INT NULL,	[c830] INT NULL, [c831] INT NULL, [c832] INT NULL, [c833] INT NULL, [c834] INT NULL, [c835] INT NULL, [c836] INT NULL, [c837] INT NULL, [c838] INT NULL, [c839] INT NULL,	[c840] INT NULL, [c841] INT NULL, [c842] INT NULL, [c843] INT NULL, [c844] INT NULL, [c845] INT NULL, [c846] INT NULL, [c847] INT NULL, [c848] INT NULL, [c849] INT NULL,	[c850] INT NULL, [c851] INT NULL, [c852] INT NULL, [c853] INT NULL, [c854] INT NULL, [c855] INT NULL, [c856] INT NULL, [c857] INT NULL, [c858] INT NULL, [c859] INT NULL,	[c860] INT NULL, [c861] INT NULL, [c862] INT NULL, [c863] INT NULL, [c864] INT NULL, [c865] INT NULL, [c866] INT NULL, [c867] INT NULL, [c868] INT NULL, [c869] INT NULL,	[c870] INT NULL, [c871] INT NULL, [c872] INT NULL, [c873] INT NULL, [c874] INT NULL, [c875] INT NULL, [c876] INT NULL, [c877] INT NULL, [c878] INT NULL, [c879] INT NULL,	[c880] INT NULL, [c881] INT NULL, [c882] INT NULL, [c883] INT NULL, [c884] INT NULL, [c885] INT NULL, [c886] INT NULL, [c887] INT NULL, [c888] INT NULL, [c889] INT NULL,	[c890] INT NULL, [c891] INT NULL, [c892] INT NULL, [c893] INT NULL, [c894] INT NULL, [c895] INT NULL, [c896] INT NULL, [c897] INT NULL, [c898] INT NULL, [c899] INT NULL,
	[c900] INT NULL, [c901] INT NULL, [c902] INT NULL, [c903] INT NULL, [c904] INT NULL, [c905] INT NULL, [c906] INT NULL, [c907] INT NULL, [c908] INT NULL, [c909] INT NULL,	[c910] INT NULL, [c911] INT NULL, [c912] INT NULL, [c913] INT NULL, [c914] INT NULL, [c915] INT NULL, [c916] INT NULL, [c917] INT NULL, [c918] INT NULL, [c919] INT NULL, 	[c920] INT NULL, [c921] INT NULL, [c922] INT NULL, [c923] INT NULL, [c924] INT NULL, [c925] INT NULL, [c926] INT NULL, [c927] INT NULL, [c928] INT NULL, [c929] INT NULL,	[c930] INT NULL, [c931] INT NULL, [c932] INT NULL, [c933] INT NULL, [c934] INT NULL, [c935] INT NULL, [c936] INT NULL, [c937] INT NULL, [c938] INT NULL, [c939] INT NULL,	[c940] INT NULL, [c941] INT NULL, [c942] INT NULL, [c943] INT NULL, [c944] INT NULL, [c945] INT NULL, [c946] INT NULL, [c947] INT NULL, [c948] INT NULL, [c949] INT NULL,	[c950] INT NULL, [c951] INT NULL, [c952] INT NULL, [c953] INT NULL, [c954] INT NULL, [c955] INT NULL, [c956] INT NULL, [c957] INT NULL, [c958] INT NULL, [c959] INT NULL,	[c960] INT NULL, [c961] INT NULL, [c962] INT NULL, [c963] INT NULL, [c964] INT NULL, [c965] INT NULL, [c966] INT NULL, [c967] INT NULL, [c968] INT NULL, [c969] INT NULL,	[c970] INT NULL, [c971] INT NULL, [c972] INT NULL, [c973] INT NULL, [c974] INT NULL, [c975] INT NULL, [c976] INT NULL, [c977] INT NULL, [c978] INT NULL, [c979] INT NULL,  	[c980] INT NULL, [c981] INT NULL, [c982] INT NULL, [c983] INT NULL, [c984] INT NULL, [c985] INT NULL, [c986] INT NULL, [c987] INT NULL, [c988] INT NULL, [c989] INT NULL,	[c990] INT NULL, [c991] INT NULL, [c992] INT NULL, [c993] INT NULL, [c994] INT NULL, [c995] INT NULL, [c996] INT NULL, [c997] INT NULL, [c998] INT NULL, [c999] INT NULL,
	[c1000] INT NULL);
GO

CREATE CLUSTERED INDEX [NonSparse_CL]
	ON [NonSparseDocRepository] ([DocID]);
	
DECLARE @RandomValue INT;
DECLARE @DocType INT;
DECLARE @DocNameLength INT;
DECLARE @ColumnStart INT;

DECLARE @DocLoop INT = 1;
DECLARE @ColumnLoop INT;

DECLARE @ExecString VARCHAR (8000);
DECLARE @ExecString2 VARCHAR (8000);

WHILE (@DocLoop < 100001)
BEGIN
	-- Calculate doc name length
	SET @DocNameLength = CONVERT (INT, RAND () * 100) + 1;
	SET @DocType = CONVERT (INT, RAND () * 49) + 1;
	SET @ColumnStart = @DocType * 20;

	-- Add the columns we're inserting into
	SELECT @ColumnLoop = @ColumnStart;
	SELECT @ExecString = ' ([DocName], [DocType], [c' +
		CAST (@ColumnLoop AS VARCHAR);
	SELECT @ColumnLoop = @ColumnLoop + 1;
	WHILE (@ColumnLoop < (@ColumnStart + 20))
	BEGIN
		SELECT @ExecString = @ExecString + '], [c' +
			CAST(@ColumnLoop AS VARCHAR);
		SELECT @ColumnLoop = @ColumnLoop + 1;
	END;
	SELECT @ExecString = @ExecString + ']) VALUES (''';

	-- Add the random document name
	SELECT @ColumnLoop = 0;
	WHILE (@ColumnLoop < @DocNameLength)
	BEGIN
		SELECT @ExecString = @ExecString + CHAR (97 +
			CONVERT (INT, RAND () * 26));
		SELECT @ColumnLoop = @ColumnLoop + 1;
	END;
		
	-- Add the random column values
	SELECT @ExecString = @ExecString + ''', ' +
		CAST (@DocType AS VARCHAR) + ', ' +
			CAST (CONVERT (INT, RAND () * 100000) AS VARCHAR);
		
	SELECT @ColumnLoop = 1;
	WHILE (@ColumnLoop < 20)
	BEGIN
		SELECT @ExecString = @ExecString + ', ' +
			CAST (CONVERT (INT, RAND () * 100000) AS VARCHAR);
		SELECT @ColumnLoop = @ColumnLoop + 1;
	END;
	SELECT @ExecString = @ExecString + ')';

	SELECT @ExecString2 =
		'INSERT INTO [NonSparseDocRepository] ' + @ExecString;
	EXEC (@ExecString2);

	SELECT @DocLoop = @DocLoop + 1;
END;
GO

