`timescale 1ns / 1ps

`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_montgomery();

    reg          clk;
    reg          resetn;
    reg          start;
    reg  [1023:0] in_a;
    reg  [1023:0] in_b;
    reg  [1023:0] in_m;
    reg  [1027:0] in_3m;
    wire [1023:0] result;
    wire         done;

    reg  [1023:0] expected;
    reg          result_ok;

    //Instantiating montgomery module
    montgomery montgomery_instance( .clk    (clk    ),
                                    .resetn (resetn ),
                                    .start  (start  ),
                                    .in_a   (in_a   ),
                                    .in_b   (in_b   ),
                                    .in_m   (in_m   ),
                                    .in_3m  (in_3m  ),
                                    .result (result ),
                                    .done   (done   ));

    //Generate a clock
    initial begin
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end

    //Reset
    initial begin
        resetn = 0;
        #`RESET_TIME resetn = 1;
    end

    // Test data
    initial begin

        #`RESET_TIME

        $display("\nMontgomery Multiplication test 1");
        
        in_a     <= 1024'h8e328b92e9180b446fb7739d3f567ef301e992679c089b20eba45a7c83484997c68b2f484fc3bb95cd783958fcabac9fd55265dc61ec5d10c78cc4172c1e0260b23da69a1de10c16bb78418a93d10569f241273446ca2879e8ccbe98ad5b42befa7d60ce94225174b5f4ac0c77d18fe5f6c2d8aa3fe12021ff95cab0cb8d22da;
        in_b     <= 1024'ha31e9037659fd5251c917ee329b30020e2ef2b55fab203ee8dba6fea2d396cfa97fd70d5d063e5a7b2d8caa1fecd147dd0b81e1f0431efbd1d764a8d5fba443c0f6f9ce5ed658dbae8ad4bf63f87a0d457d7a218953e363c9c004181d46a91d5de206a7254fc0370017f37b79a2ecdb925e2c971cdd959d288d67ae6ff8bcb66;
        in_m     <= 1024'haa9f14ab61978f1426e03f0e87fd2de456afcd407017a58966d8bf31cc9aebf5d5586d79bc2e829f2a6ba3021a50f710d175bb98f5b797f345fd503bb2a1057c88b82025a8a1b4f049d44e25926ef8e6a660ea9a910016d390f1a2ec56505ce7ab214a577291ecb5dc93109d9ba755dbec8e22d89e4733505c564c21c2cfcd31;
        in_3m    <= 1028'h1ffdd3e0224c6ad3c74a0bd2b97f789ad040f67c15046f09c348a3d9565d0c3e18009486d348b87dd7f42e9064ef2e532746132cae126c7d9d1f7f0b317e310759a286070f9e51ed0dd7cea70b74ceab3f322bfcfb300447ab2d4e8c502f116b70163df0657b5c62195b931d8d2f60193c5aa6889dad599f11502e465486f6793;
        expected <= 1024'h3b6dd06956748c37ab4c4a0c56be8251d75b067f6c121195d637e267d61215e173744ada49b0237400bd0bdf1e244bc196164dac3db591fa3344a474d8c935527005763fdd2c6c5f858923c36127d3f33d27841eabcb1b85db2d37a5482bc167081d065149ba6acdafc0b5d102b2135810c7f0051c15d2cbfb3ff38ac8498c5d;

        start<=1;
        #`CLK_PERIOD;
        start<=0;

        wait (done==1);
        #`CLK_PERIOD;
        $display("result calculated=%x", result);
        $display("result expected  =%x", expected);
        $display("error            =%x", expected-result);
        result_ok = (expected==result);
        #`CLK_PERIOD;

        $display("\nMontgomery Multiplication test 2");

        in_a     <= 1024'ha06fc8ef99086fb7cbc42e303068f5e44ada25c745952f809305aff7160d13339b184c3f6b3fd66807c875af12bc1da48843e012a410894a185eb10d02bb82d708046b5f78a6bd0d5019709b3bed6070d02764492842d75013b500ddb8b02a3e07a089719226087874d7aa28f32361c94f1fb1328ca1f4a56e566e962b5724b3;
        in_b     <= 1024'hab84df937180a3dbaef7f64cf9c919222cb44a077f3bcf5f6de850ec110af1d4b2bef1596ab10a00e804eb5df4ee622149dd1b953202981d8f2708897315eeaa14d631168eff4e870744a59674d01a6926d8e44481bb1a1429eee10f773cdb459babd40daad9c03e75658d1cbf65a4b58a834e1715adc391cdaabcc9664aed4e;
        in_m     <= 1024'hf94ae3b3d66e23a504a50232b9a7bfd1074717cef72b3f4e61a7304daf575b546db758c5406ed4ddc0ef6a69ee04524504b371d2b38dc2209bc0114063fb3a14c3447e9bafe7ca25542172ea7723d5490f3ea5bd714fcc712293e7a6d9087115723f9405032fa84fc9786a5d31e8ec66c09fd454056c131e3b9d52fd07f32e05;
        in_3m    <= 1028'h2ebe0ab1b834a6aef0def06982cf73f7315d5476ce581bdeb24f590e90e0611fd49260a4fc14c7e9942ce3f3dca0cf6cf0e1a55781aa94661d34033c12bf1ae3e49cd7bd30fb75e6ffc6458bf656b7fdb2dbbf13853ef655367bbb6f48b19534056bebc0f098ef8ef5c693f1795bac53441df7cfc1044395ab2d7f8f717d98a0f;
        expected <= 1024'h283dee8717d63f531fb6c8c5f9f8f43e830af2cb0d78d836b711e884f7c4c63626f733c66e916a7d1a6fef8cf4aa1ce2571715f0cacbbfacb9cf8e7779e2c6fcbb269e321fba2619e12b2770a95dbe53f731144050368c94931b75f039c5eb119c8163be93325608d92ed178b38f62541e2b1a04ea43c24e366897f778665408;

        start<=1;
        #`CLK_PERIOD;
        start<=0;
        wait (done==1);
        #`CLK_PERIOD;
        $display("result calculated=%x", result);
        $display("result expected  =%x", expected);
        $display("error            =%x", expected-result);
        result_ok = (expected==result);
        #`CLK_PERIOD;

        $display("\nMontgomery Multiplication test 3");

        in_a     <= 1024'h23547dcda3ff03b623822cdd58a03eafe512e257ea9277dad0f6e29770d2820bd48339b86ad840f7fa16faa58988f25e12f60415759116bf5b0bd1793158133a503c856029a7fc378ce0ca292a18ee7a9e2c780e00e5e1e828de4a2baab5f47e77837fd5d90ee8de6b18949c7f83dcce7d7338dd55aef40e71121b0017e50f93;
        in_b     <= 1024'h84a5239ef487bab23c0b69805d470d3eb649940ed6b102dc9fcbe93af701786a02b13247cd43b11c8f4b3996beb2cbba942957ab0623d6fb8746249b718102ee951c66895415759b00f7d6fd240624f2a63c8d71aff964e66d8af995c856379ef8a06047d5817c47aef079a77063a1e94a96afe73b5be6ff72b7728251feda0f;
        in_m     <= 1024'h901f1fd2e95c664ca4b7eecb7a786ae68b71d52cfecf4d4b136e6e249061e4a8c04333da3365aaf948117b267f901c9853f5991343a19f08d97953f6a49aeddad09637548bd08750c5b036b6c7a4ca35654d1079182c85c653f1036ad63d1767ab798755722c7f527c5ac888306c2282e5df9c5548fbfef03446fab953ffdbdd;
        in_3m    <= 1028'h1b05d5f78bc1532e5ee27cc626f6940b3a2557f86fc6de7e13a4b4a6db125adfa40c99b8e9a3100ebd83471737eb055c8fbe0cb39cae4dd1a8c6bfbe3edd0c99071c2a5fda37195f25110a42456ee5ea02fe7316b48859152fbd30a4082b74637026c960056857df77510599891446788b19ed4ffdaf3fcd09cd4f02bfbff9397;
        expected <= 1024'hdfc882283b4f316a0d43fa8cdcd1c66f2f22d4d9c11b29a9c536d18a9ba8b2ee79e884546757cdf092904fc43a33793a6e11f0004f8ce5e48a9172e2df61722d6ae4d4e1a1dbd8d759379132c36587d5fe3e51553ee7bca4fdfb44d13ba7b2fc44ca8f9e9e1b538291642eaaed5bec0afd7cfd6c235046f8172aadeb1317cf1;

        start<=1;
        #`CLK_PERIOD;
        start<=0;
        wait (done==1);
        #`CLK_PERIOD;
        $display("result calculated=%x", result);
        $display("result expected  =%x", expected);
        $display("error            =%x", expected-result);
        result_ok = (expected==result);
        #`CLK_PERIOD;

        $display("\nMontgomery Multiplication test 4");

        in_a     <= 1024'h2ebd3494fb970b4f46043662c8bfeb896be1e564de85134bd1a3b8c60a1d359ef950de723363a469f14cc4b6c9677531bedc637f1c567a1daedbb988853195c1755cf145e3f6c7027b7f907800bfff0cce4f7740ab73a64a462a11ac717aaf8aaae447ba730d14f7d6b5a64d3aaae756e9f94d77a31e00bcc997b344dae8512a;
        in_b     <= 1024'h3dd3d937dc9adcc0675628a6cd91cf7a00290772f772b77f0fb731fc43d5e3cff99fdddea04b3eadcdadf9f9071e0b3332c013f5854ba2412de397af6fd5bfb923415d0c7cf9b5a1619a4fa5d6c35d9379074b2ab3c947cb2778b7be2d9ec31b33fe9cb7ef4a9ffe945e7c8cb8fe3a3e50c995cfb5c9ee2133b9e5bd31c0045;
        in_m     <= 1024'ha2831fce66b9ed3d54fefa282737e4e8f60ec9e96b5a68a5cbfa085ebf62cff9c62d70cdcf23943aeedfd56bd0782fdde2bfdfd9ada657dd6364c1a32385f57cff8e3a494095f203e523f327c133cfabf68d7283cdbd3d4830f70948d1c9c8185f1ebfd19582bfd7e92650657fc6e6ea7691344593c6613d798daf19165d6ded;
        in_3m    <= 1028'h1e7895f6b342dc7b7fefcee7875a7aebae22c5dbc420f39f163ee191c3e286fed528852696d6abcb0cc9f804371688f99a83f9f8d08f307982a2e44e96a91e076feaaaedbc1c1d60baf6bd977439b6f03e3a8578b6937b7d892e51bda755d58491d5c3f74c0883f87bb72f1307f54b4bf63b39cd0bb5323b86ca90d4b431849c7;
        expected <= 1024'h68e59ed7545e71802dde555b570a49c1577c0262368713c632b16183728a6abd232ef0dc8103f5c7ed4a59d8ba74b50a8ceb64954a019abf0cc91e443f5d4097ef5242f7bb412f11ba2bee0583c8cca0f2776f46b3b8b2ae650f04d853fa2d663b4958942809b7d50eb1dce3799d62e37e86ef4975dca85fa162ea80720bcc0d;

        start<=1;
        #`CLK_PERIOD;
        start<=0;
        wait (done==1);
        #`CLK_PERIOD;
        $display("result calculated=%x", result);
        $display("result expected  =%x", expected);
        $display("error            =%x", expected-result);
        result_ok = (expected==result);
        #`CLK_PERIOD;

        $display("\nMontgomery Multiplication test 5");

        in_a     <= 1024'ha14abc4f70466285f6f25da0364bb6c61136e927c19a6679f3cf75f2903ab6e73ac155bbf8eb678447971729b250ace5be517042fdbc7fa1dcef13f952ed93573fd088ca97f80898b52528f013bc7f4451374d2fe77ee6ef2271322ae2544cc9d63445fba8a1a0b770477700ab9c7bec472324383e48f3c7fb944d1c572b5dc;
        in_b     <= 1024'h846476a6eafeadcc629f2b3286e4cf9254af42f6cec1df4ffbf8223d72ce6960588bdc354b7d292e525e37cf8ede4a2dba2205fce9e90b3daf5e44a1389e821b21abc06255fcde039c5608fc921927509875d22961b4b3c2d1cc76188c8e8ffcb76154a3640e2249bbfea8921e9916c05fd9f29c542b1c982fb70dc08eb9a67a;
        in_m     <= 1024'hcf5c196849c9d8bfa1315f36e18ac3bc008294cde4e22519174f764cbb5397a4d5255df69cb19d9d7ab245e6cfe796534b48f9287b79be09efd52ce7345b59aa0940cd256dc4772d5d3f51cdaa571a61da9786e92142d53e162ed31d1e512dc2d9ee5a78a4c59a8e589363df48671f6ab88453f040c76ef03d9a9757ccdea19f;
        in_3m    <= 1028'h26e144c38dd5d8a3ee3941da4a4a04b340187be69aea66f4b45ee62e631fac6ee7f7019e3d614d8d87016d1b46fb6c2f9e1daeb79726d3a1dcf7f86b59d120cfe1bc26770494d658817bdf568ff054f258fc694bb63c87fba428c79575af389488dcb0f69ee50cfab09ba2b9dd9355e40298cfbd0c2564cd0b8cfc607669be4dd;
        expected <= 1024'h54fc1e9c690796f05d3733faa239b579f58c9013e78f31d72fc360195abd9d4fbe4509b3f3848c7f7e233759608ef8a442448361ffe39204b1a12356f557ba4a30d30914cf986bb8e3de1f644bf378d54531828b3cd7c18b2127b82427dd6b5ae3db688e795c58c9f7916471e846b4fdf444f2d160dc028445493c65bb034873;

        start<=1;
        #`CLK_PERIOD;
        start<=0;
        wait (done==1);
        #`CLK_PERIOD;
        $display("result calculated=%x", result);
        $display("result expected  =%x", expected);
        $display("error            =%x", expected-result);
        result_ok = (expected==result);
        #`CLK_PERIOD;

        $display("\nMontgomery Multiplication test 6");

        in_a     <= 1024'h69b15a5cf48717c193e764de354cf585405b5e6e096b8ba0e1843a51b49a2d3df8fe76e2ff61525fb5e16a8b5ccf1f6f317280baa377159a61eb5bb9245368ade4241e23e807b4e6e5daa4195bff6a18888d4543e4ce11f556192535c14bd5f5e969938f301e6d497b2a80551184bc7d72b1a7180c128bf70b15f88faf57f143;
        in_b     <= 1024'h8c8b7733d94fcac617a452a89f6e7de604c7d83ddd5f08e65333c05168fc488357bf56e1cb4f10e7858e2376cfc86ccc883831680c29e7e2bc8e7e4372e75f38b107a3e8f0ee576504ca23049d7be38c08183243a5fdf1dcec4299e60e7c998175257f94c1e2d6fd8a08d47d4ed47a4f7db35dfdbce62b72fd4fefa6e713311a;
        in_m     <= 1024'h92af1db1b248c8fc82b934e2c2b7ef146ed0bb081909b50823c3557e7dd9256f5222a056eccd3308755700e315ae818f9d842df88aa52ba2feb2b657d99e95c6c25c3fd4bd6283e6e952a2428787fc9ea951442c1b1ddbd1566e070068ce9d9466791d99ef37183e9b0110bd8bec2ad66f3dedc8aaa44462b2a723c0f07c3a11;
        in_3m    <= 1028'h1b80d591516da5af5882b9ea84827cd3d4c7231184b1d1f186b4a007b798b704df667e104c6679919600502a9410b84aed88c89e99fef82e8fc1823078cdbc1544714bf7e38278bb4bbf7e6c79697f5dbfbf3cc8451599374034a15013a6bd8bd336b58cdcda548bbd1033238a3c480834db9c959ffeccd2817f56b42d174ae33;
        expected <= 1024'h91d809e9a8039e9326081507f6ff0953cb2a0d718ee94187e1019ea1e454b0e5981dc8f0265ffecfaea0fa8577c5bcf991880cdd8c2973f2f114990517b2c5b3d0f7554ee0546302a21b16c2ee34a2fa3eb839e8c3e0ea745f42349beb1f00e827b2f09671de135a53d235fffb4e7412ed402d259b42d10858c0d8fb357e8341;

        start<=1;
        #`CLK_PERIOD;
        start<=0;
        wait (done==1);
        #`CLK_PERIOD;
        $display("result calculated=%x", result);
        $display("result expected  =%x", expected);
        $display("error            =%x", expected-result);
        result_ok = (expected==result);
        #`CLK_PERIOD;

        $display("\nMontgomery Multiplication test 7");

        in_a     <= 1024'h2aaae540e20bc2c5a812fc487511fde7df12e4d65e599d1a3d73bf42f004c06a3d05aed3b39ea85ac0a0a68f09bfda4c28a65e5355df2f1804d606966caec5a2212f577821d9818f4d33b13f88d36ada1af3cd9d29a3be33373c00e3c3b55a9e1dc6252f9d651fa48b21c2bb771924de7315605ba4f81f728d536af83c1be42a;
        in_b     <= 1024'hc8f9a361e8d1e430108b550f46daec09d9b030cd2562b9df5e023e0a7182c74fbc6359c15bae3dede9e79123740939240671edeabd06b536330d9f654c49996cf7baab993100ad0c947545030ec5b6231779f84797a6ffc9a0951d796b7777ebadd4521039a61d5ef20e50d18b8d375c0312bd1d0bf5d1d9708d7ebac0ae71a5;
        in_m     <= 1024'hcba214ec56458c4c3d4ee8c6800f32f051dbc848893112f7b98f46291c816de9c7f8ae3100a503374d1f661cbd6c7804c74ebde18c6fedf826c745c605407bee945277c9f7d6e4d807ba522ffbaf8f53bff3b35c83f722d63a6b135e7b47e35bdfe912ef2260d34b9a7ffabc3cf0c3f5ab6892dfa44fa8fd4c38d86ba147558f;
        in_3m    <= 1028'h262e63ec502d0a4e4b7ecba53802d98d0f59358d99b9338e72cadd27b558449bd57ea0a9301ef09a5e75e32563845680e55ec39a4a54fc9e87455d1520fc173cbbcf7675de784ae88172ef68ff30eadfb3fdb1a158be56882af413a1b71d7aa139fbb38cd672279e2cf7ff034b6d24be10239b89eeceefaf7e4aa8942e3d600ad;
        expected <= 1024'h2b097072e313d15be6f25b60458bd4d1ac6fbb7175ec228eb2cea00018fb55f18a4bd91e5fe9174c2fb265fc4a63751cc377a7affaae3cf7f98a4f46b1a59d1d791b99c2fee6b0bc87627908d161ec2304dc07eacb62a510c6fd4c5e7e73fa3bff2df8a79d880d822efef9e7e5b43ae0fe576c4f64683ea3c81640b7ffc2e087;

        start<=1;
        #`CLK_PERIOD;
        start<=0;
        wait (done==1);
        #`CLK_PERIOD;
        $display("result calculated=%x", result);
        $display("result expected  =%x", expected);
        $display("error            =%x", expected-result);
        result_ok = (expected==result);
        #`CLK_PERIOD;

        $display("\nMontgomery Multiplication test 8");

        in_a     <= 1024'h34398a3f34ffd17c320256a2d625f026c02d2a633c22a7ff4ac6a7aa77fa7d2406631de5a268b7867db8f78372dd8e19fd17e79f081e3e6fb36225d53093e38a9ffcff7a2390576e3a87f33b83cf82a8fc6a8fecf78fd379bec3cd2d711642b9f2c3ef5b69f6616f2b80c22ed115f01f809e0c1907521ce7e3fd9690f3ac0d49;
        in_b     <= 1024'h2b1e7783a3ee495f5abc528948b6452136e07f63cb9673b2e2b488ca4ac5e50722248266e74820967d380b1740c7b2f493b3501906f7253231c12bdbe82767c95e6f0331cd4602e3508b490a465909c46923bbe42cced53d638a0050f2d5ffd20737fcb8937068644bf7f7b5c37a69b706fd1d115d74131ba38c0b7873cfd2fc;
        in_m     <= 1024'hb80d40b257d618199fbc6b7988559c44eddb9fad428840087b1a3b199ecb5d371b10913e4bcd31d353f2563ebde9ab623ba6dc98a4d98a9782ec620564aa52d5bc4eb11e7b530ce26e34c1eec78e6880d22b63f56af46de4a21709d2c07a13e5e7d870195a051b22c586043e5a00ee5445a843f3c7429b32076bdb79cac49095;
        in_3m    <= 1028'h22827c2170782484cdf35426c9900d4cec992df07c798c019714eb14cdc6217a55131b3bae3679579fbd702bc39bd0226b2f495c9ee8c9fc688c526102dfef88134ec135b71f926a74a9e45cc56ab398276822be040dd49ade6451d78416e3bb1b789504c0e0f516850920cbb0e02cafcd0f8cbdb55c7d1961643926d604db1bf;
        expected <= 1024'hb3cafba72bc1c60498fe5b5ce60f7747d16420443e8cb3c7b785be9364c5e8c824db7b1a816f71d5d52c3e0b6761bcc2efed27d0043c22d5f1bcb22fb69f65fca23269d42cecc904dfefae4b67465948ac18c39ba0d7dc3f859e2636dcc374ea5e9992b203525dd9f7c399b482f9036e43da6c2752b0e1c3a3ae39a8bd39d74;

        start<=1;
        #`CLK_PERIOD;
        start<=0;
        wait (done==1);
        #`CLK_PERIOD;
        $display("result calculated=%x", result);
        $display("result expected  =%x", expected);
        $display("error            =%x", expected-result);
        result_ok = (expected==result);
        #`CLK_PERIOD;
        
        
        $display("\nMontgomery Multiplication test 9");

        in_a     <= 1024'h842f53bc9f473cd8df184d1ad92ecebd5f2eb0c7c88f2fe256fe88fc880bd1c3ec96fd98749f07299885e8d3b55f80e0f6424728871070d76ae28c85516d594b605aac2654158a1b8e4425ee04860f77a36080b4e227e66377d6939be8ff69edf72f92e990d59042bee05b94051ecd1876299f090ab43f49d16aba5f4428e6e6;
        in_b     <= 1024'h91fd21381680c26b1ebade97317b999b313ac046ff146ea5bc2b1612c04a821dd628fa739ec7e4e28bdaf5557e933968cc5931c25a142ee9a468d678ea07c8727d43a44e6d1bc80f101e48ba49a047521175e2da9532ed5d755991c41162d994cb3d43bde10d32420c79fa58bc8bb4f08b13516a7f8f30460f4ec2fb05440048;
        in_m     <= 1024'hd108a2e8861cc718fdadea021a56458eba7eb29863504bcf1d5722d9d8f3b9fd1d9d85ba9dd6a18ada9dd292b872ca2336f24872fdd726bdeb58a2d4c827cd34a701d1c24a3baabb30910025839ef1cdc10ca48eac9ba890f0beea0c590ca18a7080381c54340806b927b6c5108602ba599fc72ac3f51bb7ad0cacad0ec29b21;
        in_3m    <= 1028'h27319e8b99256554af909be064f02d0ac2f7c17c929f0e36d5805688d8adb2df758d8912fd983e4a08fd977b829585e69a4d6d958f9857439c209e87e5877679df5057546deb3003191b300708adcd5694325edac05d2f9b2d23cbe250b25e49f5180a854fc9c18142b77244f3192082f0cdf55804bdf5327072606072c47d163;
        expected <= 1024'h4978df0848e6735c67369cad820fbbb6c4f5f89ac8855631e97984b2bb216d614a7a772c50ff69a1c10750a38c1ad2e877d079473d9870ba92b90087ca0826a29a57c8c7bed7e5f10827e5f9563a3e904951d6ee13ea5fe49a86e9e27ba75021adc7eafb622bf54ce6714e39f4cce678e22c8571cfbd64378baf900b0ab629a3;

        start<=1;
        #`CLK_PERIOD;
        start<=0;
        wait (done==1);
        #`CLK_PERIOD;
        $display("result calculated=%x", result);
        $display("result expected  =%x", expected);
        $display("error            =%x", expected-result);
        result_ok = (expected==result);
        #`CLK_PERIOD;
        
        $display("\nMontgomery Multiplication test 10");
        
        in_a     <= 1024'h92387fe41248e98db6c9e32f6946937aafdd3a192eddac21c0045d2e1f293fe8bd41ec7026ef3189d037f99033f7459262a8c8478b223456706f07fac51e0456c75c895593875508a9eab668366d34d28e05d64f4989fc62e607fec4c58469c33b057ee0badd14bd7aa771c5d0f12595c3885a5e1dc2200cd32e79f64d4d9105;
        in_b     <= 1024'h91d01581fb9309ed49ad206ab3fadf769bffac79905a26dbf7fe68448d7d630a7b5c74b81ebc45bbaf20ee083892d9ec413bf56fcae333761d5a3b8046fccb69730f1f2740465dde914ff305765bb55b015f612c8afd932140f049a0d98a6094dc214377c1aaff5ca1a77fbe0b8acf0f2f667503d7cd8cdc222a7c64f41a7295;
        in_m     <= 1024'hc84b9f71224b9e1ca276e07ab59abd6740f942b679d610b4c75c7e470e69546431dde6c2895ead778ad6e05f4e4052358f6e2189616d5fc3ae24941c56ee5ab12f6b1dddfa647b95a823255519071a89975ebb5e3cbd37c850edc5924f67fd5722397416360462ad9732787e214745d2cd4db431214feb025a72497e4c76d525;
        in_3m    <= 1028'h258e2de5366e2da55e764a17020d03835c2ebc8236d82321e56157ad52b3bfd2c9599b4479c1c0866a084a11deac0f6a0ae4a649c24481f4b0a6dbc5504cb10138e415999ef2d72c0f8696fff4b154f9cc61c321ab637a758f2c950b6ee37f80566ac5c42a20d2808c597697a63d5d17867e91c9363efc1070f56dc7ae5647f6f;
        expected <= 1024'h30a13f3b67156292184b72ad42763c9b001a2384a1f96f21a3dc462b7cddbec788ff88439e07f7383f29ac1e48d5d2160873047267f3c7c69bb90b01d1201bcf587bb7a542f96e0aa387c1ecb2dd7ad5dd4bb48cb54e8329320db1e91505a3333a7a6aceada9a29bc94695d20b48d007e38373d6a001c0fb97e9a1629d0e1660;
        
        start<=1;
        #`CLK_PERIOD;
        start<=0;
        wait (done==1);
        #`CLK_PERIOD;
        $display("result calculated=%x", result);
        $display("result expected  =%x", expected);
        $display("error            =%x", expected-result);
        result_ok = (expected==result);
        #`CLK_PERIOD;
        
        $display("\nMontgomery Multiplication test zero times zero");

        in_a     <= 1024'h0;
        in_b     <= 1024'h0;
        in_m     <= 1024'hd0c9a3d1ad6a4b901b0c156b547132d86b5f3b2e2683b3ba2a3dc111faed5d16e67ac3009c5f13d5017585da3a3b8c03c932423d3f0ace9e87998a94740a512f4f69209c9673ac6c070dc81daf301d22fa1dd6adced40b952b699e5ae2a86163840c858a67bacae36cdbf9a62fc8d919d44d2fb5a8ccec3353d966b7c2768929;
        in_3m    <= 1028'h2725ceb75083ee2b051244041fd539889421db18a738b1b2e7eb94335f0c81744b3704901d51d3b7f0460918eaeb2a40b5b96c6b7bd206bdb96cc9fbd5c1ef38dee3b61d5c35b0544152958590d905768ee5984096c7c22bf823cdb10a7f9242a8c25909f373060aa4693ecf28f5a8b4d7ce78f20fa66c499fb8c342747639b7b;
        expected <= 1024'h0;
        
        start<=1;
        #`CLK_PERIOD;
        start<=0;
        wait (done==1);
        #`CLK_PERIOD;
        $display("result calculated=%x", result);
        $display("result expected  =%x", expected);
        $display("error            =%x", expected-result);
        result_ok = (expected==result);
        #`CLK_PERIOD;
        
        $display("\nMontgomery Multiplication test (M-1) times (M-1)");


        in_a     <= 1024'hce294939be87a639adc80d1602e1f688d379769034ded5441dc0155fa924959c812a5b87c86d1a82d35b41e19066e6e5463d9bf30d79af58f665ac091a6560b2a9c36f73a75109238ab940f00de262fc4da7e62216e0d0d8e573876198f5b6dcce93b7278bfeab1cf05e024f49f6816d542ec171742ff4a830086451e24454a8;
        in_b     <= 1024'hce294939be87a639adc80d1602e1f688d379769034ded5441dc0155fa924959c812a5b87c86d1a82d35b41e19066e6e5463d9bf30d79af58f665ac091a6560b2a9c36f73a75109238ab940f00de262fc4da7e62216e0d0d8e573876198f5b6dcce93b7278bfeab1cf05e024f49f6816d542ec171742ff4a830086451e24454a8;
        in_m     <= 1024'hce294939be87a639adc80d1602e1f688d379769034ded5441dc0155fa924959c812a5b87c86d1a82d35b41e19066e6e5463d9bf30d79af58f665ac091a6560b2a9c36f73a75109238ab940f00de262fc4da7e62216e0d0d8e573876198f5b6dcce93b7278bfeab1cf05e024f49f6816d542ec171742ff4a830086451e24454a9;
        in_3m    <= 1028'h26a7bdbad3b96f2ad0958274208a5e39a7a6c63b09e9c7fcc5940401efb6dc0d5837f129759474f887a11c5a4b134b4afd2b8d3d9286d0e0ae331041b4f302217fd4a4e5af5f31b6aa02bc2d029a728f4e8f7b26644a2728ab05a9624cae124966bbb2576a3fc0156d11a06eddde38447fc8c44545c8fddf890192cf5a6ccfdfb;
        expected <= 1024'ha11b6b55492d8b907f76af882bddcdc627af52703d82084b711265c10c1a65ad7c9a098f2ef82e19ce090c68e1076b769bea74a9e6588d032d7e6a1264bbcec1cd99b0fd8d24df8aa6f0c38e33270cc7129fde82eca0d7cffc10574e2fb99a98d2e8908f2b9e303388a2688983e1c40b1086e9e896887826159810435ee4dcee;
        
        start<=1;
        #`CLK_PERIOD;
        start<=0;
        wait (done==1);
        #`CLK_PERIOD;
        $display("result calculated=%x", result);
        $display("result expected  =%x", expected);
        $display("error            =%x", expected-result);
        result_ok = (expected==result);
        #`CLK_PERIOD;
        
        $display("\nMontgomery Multiplication test small numbers");

        in_a     <= 1024'hd10e4e8131ad80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001;
        in_b     <= 1024'hd10e4e8131ad80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001;
        in_m     <= 1024'haab85cfba151b68a81079fabae9862614f174169e2d5cff4dbc184ec7fb715c39d8613d7cfc0be11e3aa180edaf36d58999d7d0dd02d3ab024a24cec5141fe9dbec0af19c88144f05c84c86b60aa35a529f7affe75805c95b8a0578e94750a0ce586eeb9704526a40156bbc28d1d2f6dec57cfe354bd63771972e7dc84ab0825;
        in_3m    <= 1028'h2002916f2e3f5239f8316df030bc92723ed45c43da8816fde93448ec57f25414ad8923b876f423a35aafe482c90da4809ccd877297087b0106de6e6c4f3c5fbd93c420d4d5983ced1158e594221fea0ef7de70ffb608115c129e106abbd5f1e26b094cc2c50cf73ec04043347a7578e49c5076fa9fe382a654c58b7958e01186f;
        expected <= 1024'h11c47c0c838116682e5b4696c625cb42da196596cddbf011ac0dbfbae743509e9767ee78eca0dc2eb2d87ec0024c7afab335c71a3043920681603fa598f02154d211468d63d7003dff09d01c63aca7193249520f9c13f9eca73e50aae6609cc0c58e8e0d165a8f1250ce8fdd0cc2a12b97571f6d17d534c7f9d48df699c727e2;
        
        start<=1;
        #`CLK_PERIOD;
        start<=0;
        wait (done==1);
        #`CLK_PERIOD;
        $display("result calculated=%x", result);
        $display("result expected  =%x", expected);
        $display("error            =%x", expected-result);
        result_ok = (expected==result);
        #`CLK_PERIOD;
        
        $finish;
    end

endmodule