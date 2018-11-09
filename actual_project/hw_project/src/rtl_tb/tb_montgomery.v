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

        $display("\nFirst Montgomery Multiplication test");
        // You can generate your own with test vector generator python script
        in_a     <= 1024'h8e328b92e9180b446fb7739d3f567ef301e992679c089b20eba45a7c83484997c68b2f484fc3bb95cd783958fcabac9fd55265dc61ec5d10c78cc4172c1e0260b23da69a1de10c16bb78418a93d10569f241273446ca2879e8ccbe98ad5b42befa7d60ce94225174b5f4ac0c77d18fe5f6c2d8aa3fe12021ff95cab0cb8d22da;
        in_b     <= 1024'ha31e9037659fd5251c917ee329b30020e2ef2b55fab203ee8dba6fea2d396cfa97fd70d5d063e5a7b2d8caa1fecd147dd0b81e1f0431efbd1d764a8d5fba443c0f6f9ce5ed658dbae8ad4bf63f87a0d457d7a218953e363c9c004181d46a91d5de206a7254fc0370017f37b79a2ecdb925e2c971cdd959d288d67ae6ff8bcb66;
        in_m     <= 1024'haa9f14ab61978f1426e03f0e87fd2de456afcd407017a58966d8bf31cc9aebf5d5586d79bc2e829f2a6ba3021a50f710d175bb98f5b797f345fd503bb2a1057c88b82025a8a1b4f049d44e25926ef8e6a660ea9a910016d390f1a2ec56505ce7ab214a577291ecb5dc93109d9ba755dbec8e22d89e4733505c564c21c2cfcd31;
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

        // Test addition with large test vectors.
        // You can generate your own vectors with testvector generator python script.
        in_a     <= 1024'ha06fc8ef99086fb7cbc42e303068f5e44ada25c745952f809305aff7160d13339b184c3f6b3fd66807c875af12bc1da48843e012a410894a185eb10d02bb82d708046b5f78a6bd0d5019709b3bed6070d02764492842d75013b500ddb8b02a3e07a089719226087874d7aa28f32361c94f1fb1328ca1f4a56e566e962b5724b3;
        in_b     <= 1024'hab84df937180a3dbaef7f64cf9c919222cb44a077f3bcf5f6de850ec110af1d4b2bef1596ab10a00e804eb5df4ee622149dd1b953202981d8f2708897315eeaa14d631168eff4e870744a59674d01a6926d8e44481bb1a1429eee10f773cdb459babd40daad9c03e75658d1cbf65a4b58a834e1715adc391cdaabcc9664aed4e;
        in_m     <= 1024'hf94ae3b3d66e23a504a50232b9a7bfd1074717cef72b3f4e61a7304daf575b546db758c5406ed4ddc0ef6a69ee04524504b371d2b38dc2209bc0114063fb3a14c3447e9bafe7ca25542172ea7723d5490f3ea5bd714fcc712293e7a6d9087115723f9405032fa84fc9786a5d31e8ec66c09fd454056c131e3b9d52fd07f32e05;
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

        // Test addition with large test vectors.
        // You can generate your own vectors with testvector generator python script.
        in_a     <= 1024'h23547dcda3ff03b623822cdd58a03eafe512e257ea9277dad0f6e29770d2820bd48339b86ad840f7fa16faa58988f25e12f60415759116bf5b0bd1793158133a503c856029a7fc378ce0ca292a18ee7a9e2c780e00e5e1e828de4a2baab5f47e77837fd5d90ee8de6b18949c7f83dcce7d7338dd55aef40e71121b0017e50f93;
        in_b     <= 1024'h84a5239ef487bab23c0b69805d470d3eb649940ed6b102dc9fcbe93af701786a02b13247cd43b11c8f4b3996beb2cbba942957ab0623d6fb8746249b718102ee951c66895415759b00f7d6fd240624f2a63c8d71aff964e66d8af995c856379ef8a06047d5817c47aef079a77063a1e94a96afe73b5be6ff72b7728251feda0f;
        in_m     <= 1024'h901f1fd2e95c664ca4b7eecb7a786ae68b71d52cfecf4d4b136e6e249061e4a8c04333da3365aaf948117b267f901c9853f5991343a19f08d97953f6a49aeddad09637548bd08750c5b036b6c7a4ca35654d1079182c85c653f1036ad63d1767ab798755722c7f527c5ac888306c2282e5df9c5548fbfef03446fab953ffdbdd;
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

        // Test addition with large test vectors.
        // You can generate your own vectors with testvector generator python script.
        in_a     <= 1024'h2ebd3494fb970b4f46043662c8bfeb896be1e564de85134bd1a3b8c60a1d359ef950de723363a469f14cc4b6c9677531bedc637f1c567a1daedbb988853195c1755cf145e3f6c7027b7f907800bfff0cce4f7740ab73a64a462a11ac717aaf8aaae447ba730d14f7d6b5a64d3aaae756e9f94d77a31e00bcc997b344dae8512a;
        in_b     <= 1024'h3dd3d937dc9adcc0675628a6cd91cf7a00290772f772b77f0fb731fc43d5e3cff99fdddea04b3eadcdadf9f9071e0b3332c013f5854ba2412de397af6fd5bfb923415d0c7cf9b5a1619a4fa5d6c35d9379074b2ab3c947cb2778b7be2d9ec31b33fe9cb7ef4a9ffe945e7c8cb8fe3a3e50c995cfb5c9ee2133b9e5bd31c0045;
        in_m     <= 1024'ha2831fce66b9ed3d54fefa282737e4e8f60ec9e96b5a68a5cbfa085ebf62cff9c62d70cdcf23943aeedfd56bd0782fdde2bfdfd9ada657dd6364c1a32385f57cff8e3a494095f203e523f327c133cfabf68d7283cdbd3d4830f70948d1c9c8185f1ebfd19582bfd7e92650657fc6e6ea7691344593c6613d798daf19165d6ded;
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

        // Test addition with large test vectors.
        // You can generate your own vectors with testvector generator python script.
        in_a     <= 1024'ha14abc4f70466285f6f25da0364bb6c61136e927c19a6679f3cf75f2903ab6e73ac155bbf8eb678447971729b250ace5be517042fdbc7fa1dcef13f952ed93573fd088ca97f80898b52528f013bc7f4451374d2fe77ee6ef2271322ae2544cc9d63445fba8a1a0b770477700ab9c7bec472324383e48f3c7fb944d1c572b5dc;
        in_b     <= 1024'h846476a6eafeadcc629f2b3286e4cf9254af42f6cec1df4ffbf8223d72ce6960588bdc354b7d292e525e37cf8ede4a2dba2205fce9e90b3daf5e44a1389e821b21abc06255fcde039c5608fc921927509875d22961b4b3c2d1cc76188c8e8ffcb76154a3640e2249bbfea8921e9916c05fd9f29c542b1c982fb70dc08eb9a67a;
        in_m     <= 1024'hcf5c196849c9d8bfa1315f36e18ac3bc008294cde4e22519174f764cbb5397a4d5255df69cb19d9d7ab245e6cfe796534b48f9287b79be09efd52ce7345b59aa0940cd256dc4772d5d3f51cdaa571a61da9786e92142d53e162ed31d1e512dc2d9ee5a78a4c59a8e589363df48671f6ab88453f040c76ef03d9a9757ccdea19f;
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

        // Test addition with large test vectors.
        // You can generate your own vectors with testvector generator python script.
        in_a     <= 1024'h69b15a5cf48717c193e764de354cf585405b5e6e096b8ba0e1843a51b49a2d3df8fe76e2ff61525fb5e16a8b5ccf1f6f317280baa377159a61eb5bb9245368ade4241e23e807b4e6e5daa4195bff6a18888d4543e4ce11f556192535c14bd5f5e969938f301e6d497b2a80551184bc7d72b1a7180c128bf70b15f88faf57f143;
        in_b     <= 1024'h8c8b7733d94fcac617a452a89f6e7de604c7d83ddd5f08e65333c05168fc488357bf56e1cb4f10e7858e2376cfc86ccc883831680c29e7e2bc8e7e4372e75f38b107a3e8f0ee576504ca23049d7be38c08183243a5fdf1dcec4299e60e7c998175257f94c1e2d6fd8a08d47d4ed47a4f7db35dfdbce62b72fd4fefa6e713311a;
        in_m     <= 1024'h92af1db1b248c8fc82b934e2c2b7ef146ed0bb081909b50823c3557e7dd9256f5222a056eccd3308755700e315ae818f9d842df88aa52ba2feb2b657d99e95c6c25c3fd4bd6283e6e952a2428787fc9ea951442c1b1ddbd1566e070068ce9d9466791d99ef37183e9b0110bd8bec2ad66f3dedc8aaa44462b2a723c0f07c3a11;
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

        // Test addition with large test vectors.
        // You can generate your own vectors with testvector generator python script.
        in_a     <= 1024'h2aaae540e20bc2c5a812fc487511fde7df12e4d65e599d1a3d73bf42f004c06a3d05aed3b39ea85ac0a0a68f09bfda4c28a65e5355df2f1804d606966caec5a2212f577821d9818f4d33b13f88d36ada1af3cd9d29a3be33373c00e3c3b55a9e1dc6252f9d651fa48b21c2bb771924de7315605ba4f81f728d536af83c1be42a;
        in_b     <= 1024'hc8f9a361e8d1e430108b550f46daec09d9b030cd2562b9df5e023e0a7182c74fbc6359c15bae3dede9e79123740939240671edeabd06b536330d9f654c49996cf7baab993100ad0c947545030ec5b6231779f84797a6ffc9a0951d796b7777ebadd4521039a61d5ef20e50d18b8d375c0312bd1d0bf5d1d9708d7ebac0ae71a5;
        in_m     <= 1024'hcba214ec56458c4c3d4ee8c6800f32f051dbc848893112f7b98f46291c816de9c7f8ae3100a503374d1f661cbd6c7804c74ebde18c6fedf826c745c605407bee945277c9f7d6e4d807ba522ffbaf8f53bff3b35c83f722d63a6b135e7b47e35bdfe912ef2260d34b9a7ffabc3cf0c3f5ab6892dfa44fa8fd4c38d86ba147558f;
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

        // Test addition with large test vectors.
        // You can generate your own vectors with testvector generator python script.
        in_a     <= 1024'h34398a3f34ffd17c320256a2d625f026c02d2a633c22a7ff4ac6a7aa77fa7d2406631de5a268b7867db8f78372dd8e19fd17e79f081e3e6fb36225d53093e38a9ffcff7a2390576e3a87f33b83cf82a8fc6a8fecf78fd379bec3cd2d711642b9f2c3ef5b69f6616f2b80c22ed115f01f809e0c1907521ce7e3fd9690f3ac0d49;
        in_b     <= 1024'h2b1e7783a3ee495f5abc528948b6452136e07f63cb9673b2e2b488ca4ac5e50722248266e74820967d380b1740c7b2f493b3501906f7253231c12bdbe82767c95e6f0331cd4602e3508b490a465909c46923bbe42cced53d638a0050f2d5ffd20737fcb8937068644bf7f7b5c37a69b706fd1d115d74131ba38c0b7873cfd2fc;
        in_m     <= 1024'hb80d40b257d618199fbc6b7988559c44eddb9fad428840087b1a3b199ecb5d371b10913e4bcd31d353f2563ebde9ab623ba6dc98a4d98a9782ec620564aa52d5bc4eb11e7b530ce26e34c1eec78e6880d22b63f56af46de4a21709d2c07a13e5e7d870195a051b22c586043e5a00ee5445a843f3c7429b32076bdb79cac49095;
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
        
        $display("\nMontgomery Multiplication zeroes test");
        
                // Test addition with large test vectors.
                // You can generate your own vectors with testvector generator python script.
                in_a     <= 1024'h0;
                in_b     <= 1024'h0;
                in_m     <= 1024'hb80d40b257d618199fbc6b7988559c44eddb9fad428840087b1a3b199ecb5d371b10913e4bcd31d353f2563ebde9ab623ba6dc98a4d98a9782ec620564aa52d5bc4eb11e7b530ce26e34c1eec78e6880d22b63f56af46de4a21709d2c07a13e5e7d870195a051b22c586043e5a00ee5445a843f3c7429b32076bdb79cac49095;
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
        $finish;
    end

endmodule
