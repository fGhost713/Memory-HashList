import StableTrieMap "mo:StableTrieMap";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Region "mo:base/Region";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import List "mo:base/List";
import Hash "mo:base/Hash";
import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Error "mo:base/Error";
import Itertools "mo:itertools/Iter";
import { MemoryRegion } "mo:memory-region";
import lib "../lib";

actor {

  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };

  Debug.print("hello0");
  type OwnType = {
    myNumber : Nat;
    myText : Text;
  };
  let ownType1 : OwnType = {
    myNumber : Nat = 2345;
    myText : Text = "Hello World3:24 So he drove out the man; and he placed at the east of the garden of Eden Cherubims, and a flaming sword which turned every way, to keep the way of the tree of life.

4:1 And Adam knew Eve his wife; and she conceived, and bare Cain, and said, I have gotten a man from the LORD.

4:2 And she again bare his brother Abel. And Abel was a keeper of sheep, but Cain was a tiller of the ground.

4:3 And in process of time it came to pass, that Cain brought of the fruit of the ground an offering unto the LORD.

4:4 And Abel, he also brought of the firstlings of his flock and of the fat thereof. And the LORD had respect unto Abel and to his offering: 4:5 But unto Cain and to his offering he had not respect. And Cain was very wroth, and his countenance fell.

4:6 And the LORD said unto Cain, Why art thou wroth? and why is thy countenance fallen? 4:7 If thou doest well, shalt thou not be accepted? and if thou doest not well, sin lieth at the door. And unto thee shall be his desire, and thou shalt rule over him.

4:8 And Cain talked with Abel his brother: and it came to pass, when they were in the field, that Cain rose up against Abel his brother, and slew him.

4:9 And the LORD said unto Cain, Where is Abel thy brother? And he said, I know not: Am I my brother’s keeper? 4:10 And he said, What hast thou done? the voice of thy brother’s blood crieth unto me from the ground.

4:11 And now art thou cursed from the earth, which hath opened her mouth to receive thy brother’s blood from thy hand; 4:12 When thou tillest the ground, it shall not henceforth yield unto thee her strength; a fugitive and a vagabond shalt thou be in the earth.

4:13 And Cain said unto the LORD, My punishment is greater than I can bear.

4:14 Behold, thou hast driven me out this day from the face of the earth; and from thy face shall I be hid; and I shall be a fugitive and a vagabond in the earth; and it shall come to pass, that every one that findeth me shall slay me.

4:15 And the LORD said unto him, Therefore whosoever slayeth Cain, vengeance shall be taken on him sevenfold. And the LORD set a mark upon Cain, lest any finding him should kill him.

4:16 And Cain went out from the presence of the LORD, and dwelt in the land of Nod, on the east of Eden.

4:17 And Cain knew his wife; and she conceived, and bare Enoch: and he builded a city, and called the name of the city, after the name of his son, Enoch.

4:18 And unto Enoch was born Irad: and Irad begat Mehujael: and Mehujael begat Methusael: and Methusael begat Lamech.

4:19 And Lamech took unto him two wives: the name of the one was Adah, and the name of the other Zillah.

4:20 And Adah bare Jabal: he was the father of such as dwell in tents, and of such as have cattle.

4:21 And his brother’s name was Jubal: he was the father of all such as handle the harp and organ.

4:22 And Zillah, she also bare Tubalcain, an instructer of every artificer in brass and iron: and the sister of Tubalcain was Naamah.

4:23 And Lamech said unto his wives, Adah and Zillah, Hear my voice; ye wives of Lamech, hearken unto my speech: for I have slain a man to my wounding, and a young man to my hurt.

4:24 If Cain shall be avenged sevenfold, truly Lamech seventy and sevenfold.

4:25 And Adam knew his wife again; and she bare a son, and called his name Seth: For God, said she, hath appointed me another seed instead of Abel, whom Cain slew.

4:26 And to Seth, to him also there was born a son; and he called his name Enos: then began men to call upon the name of the LORD.

5:1 This is the book of the generations of Adam. In the day that God created man, in the likeness of God made he him; 5:2 Male and female created he them; and blessed them, and called their name Adam, in the day when they were created.

5:3 And Adam lived an hundred and thirty years, and begat a son in his own likeness, and after his image; and called his name Seth: 5:4 And the days of Adam after he had begotten Seth were eight hundred years: and he begat sons and daughters: 5:5 And all the days that Adam lived were nine hundred and thirty years: and he died.

5:6 And Seth lived an hundred and five years, and begat Enos: 5:7 And Seth lived after he begat Enos eight hundred and seven years, and begat sons and daughters: 5:8 And all the days of Seth were nine hundred and twelve years: and he died.

5:9 And Enos lived ninety years, and begat Cainan: 5:10 And Enos lived after he begat Cainan eight hundred and fifteen years, and begat sons and daughters: 5:11 And all the days of Enos were nine hundred and five years: and he died.

5:12 And Cainan lived seventy years and begat Mahalaleel: 5:13 And Cainan lived after he begat Mahalaleel eight hundred and forty years, and begat sons and daughters: 5:14 And all the days of Cainan were nine hundred and ten years: and he died.

5:15 And Mahalaleel lived sixty and five years, and begat Jared: 5:16 And Mahalaleel lived after he begat Jared eight hundred and thirty years, and begat sons and daughters: 5:17 And all the days of Mahalaleel were eight hundred ninety and five years: and he died.

5:18 And Jared lived an hundred sixty and two years, and he begat Enoch: 5:19 And Jared lived after he begat Enoch eight hundred years, and begat sons and daughters: 5:20 And all the days of Jared were nine hundred sixty and two years: and he died.

5:21 And Enoch lived sixty and five years, and begat Methuselah: 5:22 And Enoch walked with God after he begat Methuselah three hundred years, and begat sons and daughters: 5:23 And all the days of Enoch were three hundred sixty and five years: 5:24 And Enoch walked with God: and he was not; for God took him.

5:25 And Methuselah lived an hundred eighty and seven years, and begat Lamech.

5:26 And Methuselah lived after he begat Lamech seven hundred eighty and two years, and begat sons and daughters: 5:27 And all the days of Methuselah were nine hundred sixty and nine years: and he died.

5:28 And Lamech lived an hundred eighty and two years, and begat a son: 5:29 And he called his name Noah, saying, This same shall comfort us concerning our work and toil of our hands, because of the ground which the LORD hath cursed.

5:30 And Lamech lived after he begat Noah five hundred ninety and five years, and begat sons and daughters: 5:31 And all the days of Lamech were seven hundred seventy and seven years: and he died.

5:32 And Noah was five hundred years old: and Noah begat Shem, Ham, and Japheth.

6:1 And it came to pass, when men began to multiply on the face of the earth, and daughters were born unto them, 6:2 That the sons of God saw the daughters of men that they were fair; and they took them wives of all which they chose.

6:3 And the LORD said, My spirit shall not always strive with man, for that he also is flesh: yet his days shall be an hundred and twenty years.

6:4 There were giants in the earth in those days; and also after that, when the sons of God came in unto the daughters of men, and they bare children to them, the same became mighty men which were of old, men of renown.

6:5 And God saw that the wickedness of man was great in the earth, and that every imagination of the thoughts of his heart was only evil continually.

6:6 And it repented the LORD that he had made man on the earth, and it grieved him at his heart.

6:7 And the LORD said, I will destroy man whom I have created from the face of the earth; both man, and beast, and the creeping thing, and the fowls of the air; for it repenteth me that I have made them.

6:8 But Noah found grace in the eyes of the LORD.

6:9 These are the generations of Noah: Noah was a just man and perfect in his generations, and Noah walked with God.

6:10 And Noah begat three sons, Shem, Ham, and Japheth.

6:11 The earth also was corrupt before God, and the earth was filled with violence.

6:12 And God looked upon the earth, and, behold, it was corrupt; for all flesh had corrupted his way upon the earth.

6:13 And God said unto Noah, The end of all flesh is come before me; for the earth is filled with violence through them; and, behold, I will destroy them with the earth.

6:14 Make thee an ark of gopher wood; rooms shalt thou make in the ark, and shalt pitch it within and without with pitch.

6:15 And this is the fashion which thou shalt make it of: The length of the ark shall be three hundred cubits, the breadth of it fifty cubits, and the height of it thirty cubits.

6:16 A window shalt thou make to the ark, and in a cubit shalt thou finish it above; and the door of the ark shalt thou set in the side thereof; with lower, second, and third stories shalt thou make it.

6:17 And, behold, I, even I, do bring a flood of waters upon the earth, to destroy all flesh, wherein is the breath of life, from under heaven; and every thing that is in the earth shall die.

6:18 But with thee will I establish my covenant; and thou shalt come into the ark, thou, and thy sons, and thy wife, and thy sons’ wives with thee.

6:19 And of every living thing of all flesh, two of every sort shalt thou bring into the ark, to keep them alive with thee; they shall be male and female.

6:20 Of fowls after their kind, and of cattle after their kind, of every creeping thing of the earth after his kind, two of every sort shall come unto thee, to keep them alive.

6:21 And take thou unto thee of all food that is eaten, and thou shalt gather it to thee; and it shall be for food for thee, and for them.

6:22 Thus did Noah; according to all that God commanded him, so did he.

7:1 And the LORD said unto Noah, Come thou and all thy house into the ark; for thee have I seen righteous before me in this generation.

7:2 Of every clean beast thou shalt take to thee by sevens, the male and his female: and of beasts that are not clean by two, the male and his female.

7:3 Of fowls also of the air by sevens, the male and the female; to keep seed alive upon the face of all the earth.

7:4 For yet seven days, and I will cause it to rain upon the earth forty days and forty nights; and every living substance that I have made will I destroy from off the face of the earth.

7:5 And Noah did according unto all that the LORD commanded him.

7:6 And Noah was six hundred years old when the flood of waters was upon the earth.

7:7 And Noah went in, and his sons, and his wife, and his sons’ wives with him, into the ark, because of the waters of the flood.

7:8 Of clean beasts, and of beasts that are not clean, and of fowls, and of every thing that creepeth upon the earth, 7:9 There went in two and two unto Noah into the ark, the male and the female, as God had commanded Noah.

7:10 And it came to pass after seven days, that the waters of the flood were upon the earth.

7:11 In the six hundredth year of Noah’s life, in the second month, the seventeenth day of the month, the same day were all the fountains of the great deep broken up, and the windows of heaven were opened.";
  };

  Debug.print("hello1");
  let ownType1Blob : Blob = to_candid (ownType1);
  let mem = lib.MemoryMultiHashList;

  stable var memoryItem = lib.get_new_memory_storage();

  public shared func test() : async Result.Result<Text, Text> {

    let key1 : Blob = lib.Blobify.Text.to_blob("key1");
    try {

      let lastIndex : Nat = 1_000;

      for (index in Iter.range(0, lastIndex)) {
        ignore mem.append(key1, memoryItem, ownType1Blob);
      };
    } catch (error) {
      return #err(Error.message(error));
    };

    let all_adresses = mem.get_all_memory_addresses(key1, memoryItem);
    let memText =  mem.show_memory_used(memoryItem);
    return #ok(memText);

  };

};
