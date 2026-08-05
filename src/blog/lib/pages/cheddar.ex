defmodule Blog.HomePage do
  use Tableau.Page,
    layout: Blog.BlogLayout,
    permalink: "/cheddar.html"

  use Phoenix.Component

  def template(assigns) do
    ~H"""
    <div class="cheddar-article">
      <link rel="stylesheet" href="/css/embedded-gallery.css" />
      <script type="application/json" id="embedded-gallery-context">
        <%= Phoenix.HTML.raw(gallery_context()) %>
      </script>
      <script type="importmap">
        {
          "imports": {
            "embedded-gallery": "/js/embedded-gallery.js"
          }
        }
      </script>
      <script type="module">
        import { Mount } from "embedded-gallery";
        Mount();
      </script>
      <div id="embedded-gallery-overlay-mount"></div>

      <h1>In Loving Memory of Cheddar</h1>

      <p>Originally published July 18, 2026</p>
      <p>Last revised July 25, 2026</p>

      <p class="callout info">
        All of the photographs on this page can be clicked to see a larger, full-screen version. In the full-screen viewer, for some photos, you can also view a motion photo(a short video). You can toggle between photo and video when available using the pause and play buttons.
      </p>

      <div class="toc">
        <h2>Table of Contents</h2>
        <ul>
          <li><a href={"##{id(:memorial)}"}>Memorial</a></li>
          <li><a href={"##{id(:being_cheddars_human)}"}>Being Cheddar's Human</a></li>
          <ul>
            <li><a href={"##{id(:childhood)}"}>Childhood</a></li>
            <li><a href={"##{id(:adulthood)}"}>Adulthood</a></li>
            <li><a href={"##{id(:super_senior_years)}"}>Super Senior Years</a></li>
          </ul>
          <li><a href={"##{id(:gallery)}"}>Gallery</a></li>
          <ul>
            <li><a href={"##{id(:gallery_gabes_favorites)}"}>Gabe's Favorites</a></li>
            <li><a href={"##{id(:gallery_full_collection)}"}>Full Collection</a></li>
            <ul>
              <li :for={group <- 0..3}>
                <a href={"##{gallery_group_id(group)}"}>{gallery_group_label(group)}</a>
              </li>
            </ul>
          </ul>
        </ul>
      </div>

      <h1 id={id(:memorial)}>Memorial</h1>

      <p>
        2010 - 2026
      </p>

      <p>
        <em>
          Also known as Ched, Cheddy, Chedward, Shedward, Shredward, Chompward, Chonkward, Chubward, Cheese man, Mister Puss, Cheddopuss, Book Licker
        </em>
      </p>

      <div class="gallery-grid-2">
        {gallery_grid_element("IMG_20160625_095842.jpg")}
        {gallery_grid_element("PXL_20220430_175735855.jpg")}
        {gallery_grid_element("IMG_20160406_173626.jpg")}
        {gallery_grid_element("PXL_20250803_192007810.jpg")}
      </div>

      <p>
        Cheddar passed away on the evening of June 17, 2026. He was approaching 16.5 years old. He is survived by his sister, Toast.
      </p>

      <p>
        Cheddar was a long-haired orange tabby cat. He had a white belly, boots, gloves, and bib. His coat was almost symmetrical except for his chin and the lengths of his boots.
      </p>

      <p>
        Cheddar bonded with his sister at a young age. They grew old together and were always two peas in a pod. They were companions for life.
      </p>

      <div class="gallery-grid-2">
        {gallery_grid_element("2010-02-24-9.jpg")}
        {gallery_grid_element("PXL_20260419_204001262.jpg")}
      </div>

      <p>
        Cheddar was a people-centric cat. He sought out humans and loved to spend time with them.
      </p>

      <p>
        He was a chatty guy. He would let you know when he had a request. He also was a lap cat. He would find you and then he would sit on you. He had a loud purr and frequently would share it with you, especially when he was on your lap. He also enjoyed sleeping next to and on top of people.
      </p>

      <p>
        He loved physical touch like no other feline. He loved it when you rubbed his belly. You could rub his toe beans. You could massage his face, his ears, his tail. You could pet him the wrong direction. He regularly passed the "Dangle Test". You could hang him upside down.
      </p>

      <p>He provided a playful and calming presence.</p>

      <p>
        He made a strong impression on guests. Several people who claimed to not like cats—or even to dislike cats—fell in love with him because of his friendly, gentle, and affectionate demeanor. Some people even joked about kidnapping him after visiting.
      </p>

      {inline_gallery_img_element("IMG_0208.jpg",
        class: "gallery-item gallery-opener float-left"
      )}

      <p>
        At the time of writing this, Cheddar was present for most my adult life. He was my companion for over 16 years. He was a constant. He was present in many formative moments. He became part of my identity. He represented stability.
      </p>

      <p>
        He was one of my best friends. He helped me process difficult emotions and thrive in hard times. He nurtured me when I was down. He was always delighted to spend time with me. He was always there for me.
      </p>

      <p>
        When Cheddar passed I was struck with immense guilt and despair. I was choked under a thick blanket of grief. As I recalled memories and revisited photos throughout his life it dawned on me that almost every memory I have of him is one marked by joy and happiness. Acknowledging that helped me to process my grief. He was a sunbeam in my life.
      </p>

      <p>
        I miss Cheddar dearly. My heart will forever have a Cheddar-shaped hole in it. Not an hour goes by that I don't think about him. I will never forget him. I will never stop loving him or missing him.
      </p>

      <h1 class="extra-spaced">
        Rest in peace, Cheddar.
      </h1>

      <h2 class="extra-spaced">
        Thank you for so many incredible memories. I love you ❤️
      </h2>

      <h1 id={id(:being_cheddars_human)}>Being Cheddar's Human</h1>

      <p>
        At some point during Cheddar's life I realized that I was as much his pet as he was mine. He trained me into so many behaviors. While I felt obligated to take care of him, I recognize how much he took care of me. He permeated oh-so-many facets of my life.
      </p>

      <p>
        He was my cat. I was his human.
      </p>

      <h2 id={id(:childhood)}>Childhood</h2>

      <p>
        January 1, 2010 or thereabouts was a fateful day. In a household in McKees Rocks a litter of kittens entered the world. There were two female calicos and three male orange tabbies. The runt of the litter was one of the tabbies. Mom was a resident of the house. She had become pregnant after a trip outdoors. This was not her first experience in childbirth and her owners made playful yet snide remarks about her multiple pregnancies.
      </p>

      <p>
        The household was loud, marked by the raucous noises of dogs barking and playing. Despite the loud environment, the kittens thrived. They adapted to it. In the following weeks they grew into sweet playful critters, excited by people.
      </p>

      <p>
        Meanwhile, I was a college student at the University of Pittsburgh, living off-campus with two friends, Peter and Ryan. We were struck by the urge to bring animals into our lives. We contemplated hedgehogs. We visited a pet store and browsed about. We quickly came to our senses at the petstore. Hedgehogs were impractical. Dogs were too much of a commitment. But cats seemed very interesting.
      </p>

      <p>
        When we inquired about kittens we were rudely informed that "it is not kitten season" and to come back later. I was not deterred. As it turns out, some cats do bring kittens into the world outside of kitten season.
      </p>

      {inline_gallery_img_element("2010-02-24-11.jpg",
        class: "gallery-item gallery-opener float-right"
      )}

      <p>
        In late February I stumbled upon a listing on craigslist advertising long-haired kittens for adoption. There were five of them. Peter had a car and therefore it was most convenient for him to make a visit. Originally I suggested that we adopt two male tabbies, having previously bonded with one in my childhood who was a sweet companion. Peter and his then-girlfriend made the trek. They returned with two tiny adorable kittens. It was love at first sight. The kittens were each about the size of a soda can.
      </p>

      <p>
        Notably they had decided differently than I had suggested; they brought home a calico and the tabby who was the runt. It didn't take long for me to agree that it had been a wise choise. The kittens were both stinkin' cute and sweet.
      </p>

      <p>
        Although Ryan had visited the pet store with Peter and I, we had deliberately not informed him that we were adopting kittens; It was a surprise when he returned home from class.
      </p>

      <div class="gallery-grid-2-to-4">
        {gallery_grid_element("2010-02-26-03.jpg")}
        {gallery_grid_element("2010-02-26-09.jpg")}
        {gallery_grid_element("2010-02-26-07.jpg")}
        {gallery_grid_element("2010-02-26-10.jpg")}
      </div>

      <p>
        We restricted the kittens to a single room for first their first week to keep a close watch on them and to not overwhelm them. In the meanwhile we brainstormed names. It was a challenge; coming up with good names is difficult! I had a number of questionable ideas that I'm glad we didn't proceed with—such as "Vin Diesel" and "Company". I also was personal to "Mac" as in "Mac 'n Cheese" but I thought the tabby should be Mac and I didn't like cheese as a name. After a number of days I came up with Cheddar and Toast. The tabby would be Cheddar, the Calico would be Toast. The suggestions were quickly and unanimously approved.
      </p>

      {inline_gallery_img_element("IMG_0615.jpg",
        class: "gallery-item gallery-opener float-left"
      )}

      <p>
        In the weeks that followed we let the kittens wander the rest of the house. As one might expect with three college aged males as fathers, the kittens were exposed to gratuitous levels of physical affection. Their curious and playful behaviours developed and shined.
      </p>

      <p>
        Both cats enjoyed playing with toys and running around. They regularly were enticed by fishing-rod and thing-on-a-wire varieties of toys. Cheddar would leap and dash, always excited to give chase. Toast would also give chase though she was not as coordinated. She would become possessive once she had caught a toy.
      </p>

      <p>
        We learned that they loved cardboard boxes. Both for playing with and for lounging in. Cheddar also loved to contort himself and tuck himself into questionably-sized-and-shaped spaces.
      </p>

      <p>
        In time each we began to recognize a distinctive personality in each cat. They grew into being incredibly personable. Whether it was nature or nurture, I am not sure, but I think nurture played a large part.
      </p>

      {inline_gallery_img_element("IMG_0816.jpg",
        class: "gallery-item gallery-opener float-right"
      )}

      <p>
        Cheddar lived up the the stereotype of the runt. He was not very bright, but he was trusting and mellow.
      </p>

      <p>
        There's a joke about all orange cats taking turns to communally share one brain cell. He also lived in that image.
      </p>

      <p>
        Despite his questionable intellect, he loved to spend time with people, particularly seeking physical affection from them. He was persistent in this mission, sometimes annoyingly so. He had a wet nose and would rub it on you, sometimes leaving you a little slimy. But he was soft and would reward you with happy purrs when touched. He had very little self respect. I sometimes thought of him as a dog trapped in a cat's body. He tolerated being touched in ways that no other cat would and seemed to enjoy most of it.
      </p>

      <p>
        Toast had some similar characteristics—she also loved physical affection and people—but unlike Cheddar she actually had some boundaries. She was even softer than Cheddar and would hang out with you on her own terms, sometimes just out of reach of your hand. While they were both mischievous, she had a stronger reputation for getting up to no good, while he was more renowned for sitting on you.
      </p>

      <div class="gallery-grid-2">
        {gallery_grid_element("2010-05-07.jpg")}
        {gallery_grid_element("IMG_0667.jpg")}
      </div>

      <p>
        When they were kittens Toast was the one who first played with toilet paper. But it seems she got it out of her system early. She didn't show much interest in it past her youth. Cheddar, on the other hand, decimated a roll of toilet paper numerous times, even once fully grown.
        <em>For the rest of his life I kept rolls of toilet paper out of his line of sight.</em>
      </p>

      <p>
        We lived as one big happy family in that house for about 1.5 years. Many fond memories were had. The kittens grew from childhood to teenhood to adulthood.
      </p>

      <div class="gallery-grid-2">
        {gallery_grid_element("2010-05-09-2.jpg")}
        {gallery_grid_element("2010-05-09.jpg")}
      </div>

      <p>
        I took it upon myself to complete the kitty chores every day. Because I was usually the "meat man" I became the de facto dad; they bonded with me.
      </p>

      <h2 id={id(:adulthood)}>Adulthood</h2>

      <p>
        By the end of college it became apparent that Peter, Ryan, and I each were going to move out to different places. I suggested that I take the cats with me and that I be responsible for them. The other dads approved.
      </p>

      <p>
        I was fortunate enough to have a job lined up when I graduated. It was in the environmental consulting industry. I moved about 30 miles away, from Pittsburgh, PA to Washington, PA, to be closer to it.
      </p>

      <p>
        I remember feeling anxious on the drive while moving. It was on that drive that I learned Cheddar meowed non-stop, probably once every 30 seconds, when he was being transported in a carrier in a car.
      </p>

      <p>
        I was on my own for the first time in my life. I felt tremendously isolated. I had no friends living nearby. I was in a new place. On the weekends I would drive back to Pittsburgh to visit my then-girlfriend. I had a Mon-Fri, 9-5 job. But other than that I had to come up with ways to not let the isolation get to me.
      </p>

      <div class="gallery-grid-2">
        {gallery_grid_element("IMG_20111217_233748.jpg")}
        {gallery_grid_element("IMG_20111217_233927.jpg")}
      </div>

      <p>
        In time the cats grew into being companions. They became my best buddies. They always kept me company. Our relationship became more symbiotic. It nurtured me. I provided sustenance, attention, and a lap. They provided physical affection and antics.
      </p>

      <p>
        I treated my time in Washington, PA. as deliberately ephemeral. It was a stepping stone along my path. I didn't set down roots. The work was OK but it motivated me little and I found myself longing for meaning and more mental stimulation. I felt trapped in a parochial environment. I longed for a next step and actively searched for it.
      </p>

      <div class="gallery-grid-2-to-4">
        {gallery_grid_element("IMG_1027.jpg")}
        {gallery_grid_element("IMG_1028.jpg")}
        {gallery_grid_element("IMG_20110805_170932.jpg")}
        {gallery_grid_element("IMG_20110808_181425.jpg")}
      </div>

      <p>
        I explored ideas about what to do next with my life. Eventually I began learning how to write software in my spare time. That scratched an itch. It engaged my brain. I found it exciting. It planted a seed. I began spending more and more of my free time learning how to program.
      </p>

      <p>
        My efforts were fruitful beyond just scratching a personal interest. I managed to land a job in the software industry, at a company based near Pittsburgh. After a year and a half of living in Washington, PA, I switched careers and successfully left that era of my life. I moved back to Pittsburgh once more, moving in with my then-girlfriend. I felt relieved to be through the isolation.
      </p>

      {inline_gallery_img_element("IMG_20130526_143603.jpg",
        class: "gallery-item gallery-opener float-left"
      )}

      <p>
        The new job was exciting and rocketed my knowledge and abilities to new highs. I was happy with the new environment and it was rewarding. It initially was a perfect fit for what I was seeking. I learned and grew. I opted to stay put instead of treating it as another stepping stone.
      </p>

      <p>
        The years passed. Over time the initial happiness ebbed and gave way to routine. My contentedness eventually became complacency. I stopped challenging myself. I became complacent in my personal life, too.
      </p>

      <p>
        My relationship with my then-girlfriend changed from something resembling partnership to something more like roommates. In 2015 it culminated in a break-up. Initially I had a hard time accepting the reality of the situation.
      </p>

      <p>
        After some reflection I took the opportunity to move out and live on my own once again. I needed space to emotionally recover and changing environments helped. I managed to motivate myself to keep my chin up. I picked up new hobbies. I learned that it's easier to make change effective when you bundle it all together at once.
      </p>

      {inline_gallery_img_element("IMG_20160228_093303.jpg",
        class: "gallery-item gallery-opener float-right"
      )}

      <p>
        It felt like I was starting my life anew, but unlike when I left for Washington, PA, I was more excited and sure of myself. In this period I had a couple stints staying at places that I found on craigslist. One place for three months, the next for nine months.
      </p>

      <p>
        Through these times I felt isolated again but I had the stability of working at the same job and with the same colleagues through it. My professional interests kept me afloat, engaged, and on a healthy path; I managed to avoid falling into bad habits. In time I began to put myself into more social situations to meet new folks and broaden my circles.
      </p>

      <p>
        Despite changing environments the cats remained a constant in my life. They never were bothered by change. They always adapted to their new homes and to new people. They were resilient. And, in a way, they made me resilient, too.
      </p>

      <p>
        In my home life I always felt loved and cared for, regardless of where it was. Two sweet, affectionate kitties always wanted to spend time with me. We provided stability to eachother.
      </p>

      {inline_gallery_img_element("IMG_20161029_143835.jpg",
        class: "gallery-item gallery-opener float-left"
      )}

      <p>
        In October 2016 I purchased a house and began to put down metaphorical roots. The house was a short walk from Peter, one of the other "cat dads" who by then had moved back to Pittsburgh.
      </p>

      <p>
        And a few years after that Ryan, the third "cat dad", moved back to Pittsburgh, also to a house within walking distance.
      </p>

      <p>
        Being able to so easily hang out with friends was a blessing. Being able to have the other cat dads stop by when I was away was also a blessing. Life was good. The uneasiness of isolation was a thing of the past.
      </p>

      <p>
        When I was first getting to know Sarah, my then-girlfriend, now-wife, I was excited to introduce her to the kitties. She did not grow up with cats and was apprehensive at the prospect of picking them up. We joked about the Nathan Pyle/Strange Planet cartoon—"respect the deathblades". But in reality that applied little to these cats; they loved humans.
      </p>

      {inline_gallery_img_element("PXL_20231217_224202264.jpg",
        class: "gallery-item gallery-opener float-right"
      )}

      <p>
        It didn't take long for Sarah to learn how to pick them up. Eventually she moved in. And along the way the cats bonded with her.
      </p>

      <p>
        When COVID lockdowns happened my workplace switched from being in-office to working remotely from home. As a result I started to spend most of my waking hours in the house. The amount of time I spent around the cats soared. So too did the number of cat photos in my life.
      </p>

      <p>
        Soon my colleagues met Cheddar and Toast on calls and got to know them by name. My cat-man identity changed from being a private one to a public one.
      </p>

      {inline_gallery_img_element("PXL_20220907_215329887.jpg",
        class: "gallery-item gallery-opener float-left"
      )}

      <p>
        Cheddar's lap cat tendencies quickly became notorious. I would move his legs to make him wave at colleagues on camera or showcase how he enjoyed tummy rubs or even bean rubs.
      </p>

      <p>
        One colleague asked what drugs I gave them to make them be so chill.
      </p>

      <h2 id={id(:super_senior_years)}>Super Senior Years</h2>

      <p>
        The years flew by. At some point we realized that the cats were "geriatric" or "super senior". They didn't seem to change much or slow down dramatically, which made it initially seem like a silly label.
      </p>

      <div class="gallery-grid-2">
        {gallery_grid_element("PXL_20231212_191642003.jpg")}
        {gallery_grid_element("PXL_20231212_191647567_exported_299_1702408740658.jpg")}
      </div>

      <p>
        Cheddar continued to exemplify his affectionate qualities. He also developed a number of new, heart-warming habits.
      </p>

      <p>
        Sarah and I would sit at a bench at our dinner table when we ate dinner. He realized this and would jump up on the bench and sit between us. He would then attempt to sit on my lap and would rub his wet nose on me. We took to sitting immediately aside another in order to prevent him from being able to jump between us.
      </p>

      {inline_gallery_img_element("PXL_20240406_155843772.jpg",
        class: "gallery-item gallery-opener float-right"
      )}

      <p>
        He regularly would visit at bed time, expecting to lie on top of me or next to me. When the temperature was cool it was a blessing. He was a space-heater, a source of white-noise, and lovingly affectionate. When the temperature was too high, however, his presence was bothersome. I would move him further away, sometimes entirely off of the bed. Frequently he would return and it became an exercise in futility trying to keep him away.
      </p>

      <p>
        Cheddar would sometimes sleep just above us in bed. We joked that his loud purr and close positioning was him trying to give us deep brain stimulation or him trying to send "good vibes". Sometimes his purr was so loud that we couldn't fall asleep. Sometimes his warmth would make our heads hot. We eventually came to say that he was "trying to be a hat" and would complain about inadequate sleep as a result.
      </p>

      {inline_gallery_img_element("PXL_20241127_022451029.jpg",
        class: "gallery-item gallery-opener float-left"
      )}

      <p>
        He continued to exercise his love for humans. He would regularly greet people at the door. He would come bounding to you when he saw you and, if allowed, would proceed to park himself on your lap.
      </p>

      <p>
        And if you so much as began to think about getting up from the couch, he would come over and firmly plant himself on your lap.
      </p>

      <h1 id={id(:gallery)}>Gallery</h1>
      <h2 id={id(:gallery_gabes_favorites)}>Gabe's Favorites</h2>
      <div class="gallery-grid-2-to-4">
        <div
          :for={entry <- favorites()}
          class="gallery-item"
        >
          {inline_gallery_img_element(entry, class: "gallery-grid-item gallery-opener")}
        </div>
      </div>

      <h2 id={id(:gallery_full_collection)}>Full Collection</h2>
      <p>
        <em>
          For the cat lovers out there. I tried my best to weed down the number of photos to share, but I could only get the number as low as {entries()
          |> length()}. Enjoy!
        </em>
      </p>
      <div :for={{group_index, entries} <- grouped_entries()}>
        <h3 id={gallery_group_id(group_index)}>{gallery_group_label(group_index)}</h3>
        <div class="gallery-grid-2-to-4">
          <div
            :for={entry <- entries}
            class="gallery-item"
          >
            {inline_gallery_img_element(entry,
              class: "gallery-grid-item gallery-opener",
              obscure_navigation: false
            )}
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp entries() do
    [
      %{
        label: "Meeting the kittens",
        date: "2010-02-24",
        filename: "2010-02-24-11.jpg",
        video: false
      },
      %{label: "Kitten energy", date: "2010-02-26", filename: "2010-02-26-01.jpg", video: false},
      %{label: "Kitten energy", date: "2010-02-26", filename: "2010-02-26-02.jpg", video: false},
      %{label: "Kitten energy", date: "2010-02-26", filename: "2010-02-26-03.jpg", video: false},
      %{
        label: "Curious about humans",
        date: "2010-02-26",
        filename: "2010-02-26-04.jpg",
        video: false
      },
      %{label: "Kitten energy", date: "2010-02-26", filename: "2010-02-26-05.jpg", video: false},
      %{label: "A warm lap!", date: "2010-02-26", filename: "2010-02-26-06.jpg", video: false},
      %{label: "A warm lap!", date: "2010-02-26", filename: "2010-02-26-07.jpg", video: false},
      %{label: "A warm lap!", date: "2010-02-26", filename: "2010-02-26-08.jpg", video: false},
      %{label: "Snuggly Toast", date: "2010-02-26", filename: "2010-02-26-09.jpg", video: false},
      %{
        label: "Testing the toilet paper",
        date: "2010-02-26",
        filename: "2010-02-26-10.jpg",
        video: false
      },
      %{label: "Scaling dad", date: "2010-02-26", filename: "2010-02-26-11.jpg", video: false},
      %{
        label: "Grabbing a drink",
        date: "2010-02-26",
        filename: "2010-02-26-12.jpg",
        video: false
      },
      %{
        label: "Snoozing under my bed",
        date: "2010-04-03",
        filename: "2010-04-03.jpg",
        video: false
      },
      %{
        label: "Show-casing his prominent M",
        date: "2010-04-10",
        filename: "2010-04-10.jpg",
        video: false
      },
      %{label: "Spooning snugs", date: "2010-04-17", filename: "2010-04-17.jpg", video: false},
      %{
        label: "Enjoying tummy rubs",
        date: "2010-04-25",
        filename: "2010-04-25.jpg",
        video: false
      },
      %{label: "Shoulder cat", date: "2010-05-03", filename: "2010-05-03.jpg", video: false},
      %{label: "Shoulder cat", date: "2010-05-09", filename: "2010-05-09-2.jpg", video: false},
      %{label: "Shoulder cat", date: "2010-05-09", filename: "2010-05-09.jpg", video: false},
      %{label: "Dead bug pose", date: "2010-05-23", filename: "2010-05-23.jpg", video: false},
      %{
        label: "High intensity tummy rubs",
        date: "2010-05-??",
        filename: "2010-05-ish.jpg",
        video: false
      },
      %{label: "Lapcat", date: "2010-08-06", filename: "IMG_0326.jpg", video: false},
      %{
        label:
          "Cheddar contorted himself into this box and we made it even more compact by creating a hole for his head to poke out.",
        date: "2010-09-17",
        filename: "IMG_0584.jpg",
        video: false
      },
      %{
        label: "Awkward voyeur pose",
        date: "2010-10-ish",
        filename: "2010-10-ish.jpg",
        video: false
      },
      %{label: "More contortionism", date: "2010-09-21", filename: "IMG_0615.jpg", video: false},
      %{
        label:
          "For a period of time I tried to toilet train the cats. I made progress but I stopped the experiment when we got a new roommate I didn't want to scare off.",
        date: "2011-02-23",
        filename: "IMG_0880.jpg",
        video: false
      },
      %{
        label: "Keeping a watch out the window",
        date: "2011-06-12",
        filename: "IMG_1027.jpg",
        video: false
      },
      %{
        label: "Inside's more exciting, evidently",
        date: "2011-06-12",
        filename: "IMG_1028.jpg",
        video: false
      },
      %{
        label: "Shoulder cat",
        date: "2011-12-17",
        filename: "IMG_20111217_233748.jpg",
        video: false
      },
      %{
        label: "Shoulder cat",
        date: "2011-12-17",
        filename: "IMG_20111217_233927.jpg",
        video: false
      },
      %{
        label: "Being pitiful in his cone after a UTI",
        date: "2013-04-28",
        filename: "IMG_20130428_114440.jpg",
        video: false
      },
      %{
        label: "Sibling wrestling session",
        date: "2013-05-26",
        filename: "IMG_20130526_143603.jpg",
        video: false
      },
      %{label: "A study in brown", date: "2013-08-08", filename: "2013-08-08.jpg", video: false},
      %{label: "Front row seat", date: "2014-03-01", filename: "IMGP2238.jpg", video: false},
      %{
        label: "A brief outdoors expedition",
        date: "2014-12-25",
        filename: "IMGP2846.jpg",
        video: false
      },
      %{
        label: "Cat furniture",
        date: "2015-12-14",
        filename: "IMG_20151214_222631.jpg",
        video: false
      },
      %{
        label: "Family portrait",
        date: "2016-01-01",
        filename: "IMG_20160101_184559.jpg",
        video: false
      },
      %{
        label: "Dead bug pose",
        date: "2016-01-03",
        filename: "IMG_20160103_095426.jpg",
        video: false
      },
      %{
        label: "Hanging out on dad",
        date: "2016-01-06",
        filename: "IMG_20160106_195438.jpg",
        video: false
      },
      %{
        label: "Family portrait",
        date: "2016-01-09",
        filename: "IMG_20160109_192658.jpg",
        video: false
      },
      %{
        label: "Family portrait",
        date: "2016-01-17",
        filename: "IMG_20160117_164955.jpg",
        video: false
      },
      %{
        label: "Looking handsome",
        date: "2016-01-29",
        filename: "IMG_20160129_080411.jpg",
        video: false
      },
      %{
        label: "Utter bliss, dead bug pose sleep",
        date: "2016-04-06",
        filename: "IMG_20160406_173626.jpg",
        video: false
      },
      %{
        label: "Morning snuggles",
        date: "2016-04-09",
        filename: "IMG_20160409_102744.jpg",
        video: false
      },
      %{
        label: "Leaning in for a sniff",
        date: "2016-06-25",
        filename: "2016-06-25.gif",
        video: false
      },
      %{
        label: "Looking handsome",
        date: "2016-06-25",
        filename: "IMG_20160625_095842.jpg",
        video: false
      },
      %{
        label: "Content hanging out in a new box",
        date: "2016-10-10",
        filename: "IMG_20161010_223546.jpg",
        video: false
      },
      %{
        label: "Cheddar loved to lick fingers",
        date: "2016-10-21",
        filename: "IMG_20161021_235616.jpg",
        video: false
      },
      %{
        label: "Cheddar loved to lick fingers",
        date: "2016-10-23",
        filename: "IMG_20161023_161737.jpg",
        video: false
      },
      %{
        label: "Sibling wrestling session with dramatic tail flapping",
        date: "2016-10-28",
        filename: "2016-10-28-2.gif",
        video: false
      },
      %{
        label: "Sibling wrestling session with dramatic tail flapping",
        date: "2016-10-28",
        filename: "2016-10-28.gif",
        video: false
      },
      %{
        label: "Dead bug pose next to dad",
        date: "2016-11-08",
        filename: "IMG_20161108_220329.jpg",
        video: false
      },
      %{
        label: "We learned to leave our laptops semi-closed after a couple incidents like this",
        date: "2016-11-13",
        filename: "IMG_20161113_204255.jpg",
        video: false
      },
      %{
        label: "Siblings up on a high spot",
        date: "2016-11-20",
        filename: "IMG_20161120_121039.jpg",
        video: false
      },
      %{label: "Nose boop", date: "2016-12-15", filename: "2016-12-15.jpg", video: false},
      %{label: "Chest rub", date: "2016-12-18", filename: "2016_12_18_201326.gif", video: false},
      %{
        label: "Videocall with the dads",
        date: "2017-01-ish",
        filename: "2017-01-ish.jpg",
        video: false
      },
      %{
        label: "Morning scene",
        date: "2017-03-10",
        filename: "IMG_20170310_073904.jpg",
        video: false
      },
      %{
        label: "One time he failed to unhook his claw from a toy and it traveled around with him",
        date: "2017-03-12",
        filename: "IMG_20170312_155908.jpg",
        video: false
      },
      %{
        label: "Dead bug snooze",
        date: "2017-05-29",
        filename: "IMG_20170529_131750.jpg",
        video: false
      },
      %{
        label: "Being very sneaky",
        date: "2017-06-04",
        filename: "IMG_20170604_183055.jpg",
        video: false
      },
      %{label: "Snuggle with dad", date: "2017-06-23", filename: "2017-06-23.jpg", video: false},
      %{
        label: "Patiently awaiting breakfast",
        date: "2017-08-16",
        filename: "IMG_20170816_074136.jpg",
        video: false
      },
      %{
        label: "Cheddar was used as a fly swatter a couple times",
        date: "2017-09-16",
        filename: "2017-09-16.gif",
        video: false
      },
      %{
        label: "Gracing my new table",
        date: "2017-09-28",
        filename: "IMG_20170928_081207.jpg",
        video: false
      },
      %{
        label: "Cheddar passed the dangle test with flying colors",
        date: "2017-12-22",
        filename: "IMG_20171222_005703.jpg",
        video: false
      },
      %{
        label: "Looking handsome on his 8th birthday",
        date: "2018-01-01",
        filename: "IMG_20180101_122305.jpg",
        video: false
      },
      %{
        label: "Bundled up",
        date: "2018-03-03",
        filename: "IMG_20180303_161253.jpg",
        video: false
      },
      %{
        label: "Bundled up",
        date: "2018-03-03",
        filename: "IMG_20180303_173020.jpg",
        video: false
      },
      %{label: "Hey!", date: "2018-03-28", filename: "IMG_20180328_165314.jpg", video: false},
      %{
        label: "A squeeze with dad",
        date: "2018-04-07",
        filename: "IMG_20180407_113846.jpg",
        video: false
      },
      %{
        label: "Enjoying a scritch",
        date: "2018-08-ish",
        filename: "2018-08-ish.gif",
        video: false
      },
      %{
        label: "Impromptu boudoir moment",
        date: "2018-11-03",
        filename: "IMG_20181103_113234.jpg",
        video: false
      },
      %{
        label: "Catnip aggression",
        date: "2018-10-29",
        filename: "MVIMG_20181029_184540.jpg",
        video: true
      },
      %{
        label: "Coming in hot for a fingie lick and gumming",
        date: "2018-12-21",
        filename: "MVIMG_20181221_231749.jpg",
        video: true
      },
      %{
        label: "A cactus can make for a great massage tool",
        date: "2019-01-01",
        filename: "MVIMG_20190101_145542.jpg",
        video: true
      },
      %{
        label: "Getting a scritch on his 9th birthday",
        date: "2019-01-01",
        filename: "MVIMG_20190101_144521.jpg",
        video: true
      },
      %{
        label: "Lickin' fingies on his 9th birthday",
        date: "2019-01-01",
        filename: "MVIMG_20190101_144607.jpg",
        video: true
      },
      %{
        label: "Selfie pose on his 9th birthday",
        date: "2019-01-01",
        filename: "MVIMG_20190101_150022.jpg",
        video: true
      },
      %{
        label: "Shmoozin'",
        date: "2019-01-12",
        filename: "IMG_20190112_215124.jpg",
        video: false
      },
      %{
        label: "Hanging out in the shoe and coat pile",
        date: "2019-01-19",
        filename: "2019-01-19.jpg",
        video: false
      },
      %{label: "Hanging with dad", date: "2019-06-21", filename: "IMG_3574.jpg", video: false},
      %{
        label: "Having a stretch",
        date: "2019-07-15",
        filename: "MVIMG_20190715_184356.jpg",
        video: true
      },
      %{
        label: "Blissed out in dead bug pose",
        date: "2019-09-15",
        filename: "MVIMG_20190915_180543.jpg",
        video: true
      },
      %{
        label: "Bird watching",
        date: "2019-09-28",
        filename: "MVIMG_20190928_122337.jpg",
        video: true
      },
      %{
        label: "Bird watching",
        date: "2019-09-28",
        filename: "MVIMG_20190928_122410.jpg",
        video: true
      },
      %{
        label: "Every year when the heat kicked on they would quickly sit on the registers",
        date: "2019-11-02",
        filename: "MVIMG_20191102_123317.jpg",
        video: true
      },
      %{
        label:
          "Sometimes when they got tired of one another they would secretly snuggle through a blanket like this.",
        date: "2019-11-05",
        filename: "MVIMG_20191105_151718.jpg",
        video: true
      },
      %{
        label: "Shmoozin'",
        date: "2019-12-24",
        filename: "IMG_20191224_125421.jpg",
        video: false
      },
      %{
        label: "Dead bug snuggle",
        date: "2020-02-10",
        filename: "MVIMG_20200210_115346.jpg",
        video: true
      },
      %{
        label: "Dad-suspended scritch",
        date: "2020-02-29",
        filename: "IMG_4203.jpg",
        video: false
      },
      %{
        label: "Hanging out in the kitchen with dad",
        date: "2020-03-01",
        filename: "2020-03-01.jpg",
        video: false
      },
      %{
        label: "Cheddar passed the dangle test with flying colors",
        date: "2020-03-01",
        filename: "MVIMG_20200301_172233.jpg",
        video: true
      },
      %{label: "Double scoop", date: "2020-03-24", filename: "IMG_4355.jpg", video: false},
      %{
        label: "Guest visit through the window during COVID lockdowns",
        date: "2020-04-17",
        filename: "2020-04-17.jpg",
        video: false
      },
      %{
        label: "Guest visit through the window during COVID lockdowns",
        date: "2020-04-17",
        filename: "IMG_20200417_165414.jpg",
        video: false
      },
      %{label: "Tummy rub", date: "2020-04-19", filename: "IMG_4640.jpg", video: false},
      %{
        label: "Evening scene",
        date: "2020-04-22",
        filename: "MVIMG_20200422_222941.jpg",
        video: true
      },
      %{label: "Suspended tummy rub", date: "2020-05-09", filename: "IMG_0048.jpg", video: true},
      %{
        label: "Enjoying a pet on top of dad",
        date: "2020-05-24",
        filename: "IMG_0081.jpg",
        video: true
      },
      %{
        label: "Dead bug snooze",
        date: "2020-05-26",
        filename: "MVIMG_20200526_164940.jpg",
        video: true
      },
      %{
        label: "Getting an aggressive tummy rub mid-snooze",
        date: "2020-05-26",
        filename: "MVIMG_20200526_165004.jpg",
        video: true
      },
      %{label: "New seat identified", date: "2020-05-30", filename: "IMG_0124.jpg", video: true},
      %{
        label:
          "Embracing on the couch. I liked to hold him and position his legs around me like he was hugging me.",
        date: "2020-06-18",
        filename: "IMG_0208.jpg",
        video: true
      },
      %{
        label: "Sometimes they did the same thing at the same time",
        date: "2020-06-25",
        filename: "MVIMG_20200625_091634.jpg",
        video: true
      },
      %{label: "Tummy rub", date: "2020-07-01", filename: "IMG_0249.gif", video: false},
      %{
        label: "Dead bug snooze",
        date: "2020-07-08",
        filename: "MVIMG_20200708_124100.jpg",
        video: true
      },
      %{
        label: "Straddling the chair",
        date: "2020-07-10",
        filename: "MVIMG_20200710_132944.jpg",
        video: true
      },
      %{
        label: "Enjoying a pet on top of dad",
        date: "2020-07-18",
        filename: "IMG_0299.jpg",
        video: true
      },
      %{
        label: "Completely asleep",
        date: "2020-08-04",
        filename: "MVIMG_20200804_132333.jpg",
        video: true
      },
      %{label: "Looking handsome", date: "2020-08-15", filename: "IMG_0371.jpg", video: true},
      %{label: "Double scoop", date: "2020-08-15", filename: "IMG_0389.jpg", video: true},
      %{label: "Double scoop", date: "2020-09-04", filename: "IMG_0506.jpg", video: true},
      %{label: "Double scoop", date: "2020-09-07", filename: "IMG_0520.jpg", video: true},
      %{
        label: "Action shot",
        date: "2020-12-25",
        filename: "PXL_20201225_154257541.jpg",
        video: true
      },
      %{
        label: "Looking handsome",
        date: "2021-01-01",
        filename: "PXL_20210101_171344010.jpg",
        video: true
      },
      %{label: "Cheddar hat", date: "2021-03-11", filename: "IMG_1171.jpg", video: true},
      %{
        label: "Glamour shot",
        date: "2021-03-14",
        filename: "PXL_20210314_174508375.jpg",
        video: true
      },
      %{label: "Snoozing on dad", date: "2021-04-04", filename: "IMG_1232.jpg", video: true},
      %{
        label: "Enjoying a seat on top of dad",
        date: "2021-04-07",
        filename: "IMG_1246.jpg",
        video: true
      },
      %{label: "Double scoop", date: "2021-04-09", filename: "IMG_1253.jpg", video: true},
      %{
        label: "Enjoying a sternum scritch",
        date: "2021-04-21",
        filename: "IMG_1275.jpg",
        video: true
      },
      %{label: "Posing", date: "2021-05-03", filename: "PXL_20210504_003910978.jpg", video: true},
      %{label: "Posing", date: "2021-05-03", filename: "PXL_20210504_010357838.jpg", video: true},
      %{label: "Posing", date: "2021-05-03", filename: "PXL_20210504_011400600.jpg", video: true},
      %{
        label: "Inspectors hard at work",
        date: "2021-05-22",
        filename: "PXL_20210523_002724202.jpg",
        video: true
      },
      %{label: "Dead bug", date: "2021-05-23", filename: "IMG_1362.jpg", video: false},
      %{
        label: "Completely asleep",
        date: "2021-06-11",
        filename: "PXL_20210611_024021800.jpg",
        video: true
      },
      %{label: "Looking handsome", date: "2021-06-19", filename: "IMG_1445.jpg", video: false},
      %{label: "Summer grooming", date: "2021-06-20", filename: "IMG_1447.jpg", video: false},
      %{label: "Hanging with dad", date: "2021-07-09", filename: "IMG_1489.jpg", video: false},
      %{
        label: "Dead bug stretch",
        date: "2021-08-04",
        filename: "PXL_20210804_191914684.jpg",
        video: true
      },
      %{label: "Double scoop", date: "2021-10-22", filename: "IMG_1936.jpg", video: false},
      %{label: "Tummy rub", date: "2021-11-12", filename: "IMG_2002.jpg", video: false},
      %{
        label: "Interrupted mid-people watching",
        date: "2021-11-21",
        filename: "IMG_2016.jpg",
        video: false
      },
      %{label: "Snuggin", date: "2021-11-21", filename: "IMG_2021.jpg", video: false},
      %{label: "Family", date: "2021-11-25", filename: "PXL_20211126_014020961.jpg", video: true},
      %{
        label: "Fingie inspection",
        date: "2021-11-26",
        filename: "PXL_20211127_055942925.jpg",
        video: true
      },
      %{
        label: "Tummy rub on dad",
        date: "2021-11-28",
        filename: "PXL_20211128_200953279.jpg",
        video: true
      },
      %{label: "Shoulder cat", date: "2021-12-25", filename: "IMG_2126.jpg", video: false},
      %{label: "Snoozing on dad", date: "2021-12-31", filename: "IMG_2137.jpg", video: false},
      %{
        label: "Looking handsome on his 12th birthday",
        date: "2022-01-01",
        filename: "PXL_20220101_154416570.jpg",
        video: true
      },
      %{label: "Looking handsome", date: "2022-01-23", filename: "IMG_2238.jpg", video: false},
      %{
        label: "Checking out new places",
        date: "2022-03-13",
        filename: "IMG_2384.jpg",
        video: false
      },
      %{label: "Hanging out on dad", date: "2022-03-15", filename: "IMG_2394.jpg", video: false},
      %{label: "Enjoying a tummy rub", date: "2022-04-17", filename: "IMG_2469.jpg", video: true},
      %{label: "Inverted tummy rub", date: "2022-07-10", filename: "IMG_2778.jpg", video: true},
      %{
        label: "Cube shelf apartment",
        date: "2022-08-01",
        filename: "IMG_2851.jpg",
        video: false
      },
      %{
        label: "Double scoop",
        date: "2022-08-17",
        filename: "PXL_20220818_023732249.jpg",
        video: false
      },
      %{
        label: "Office chair double scoop",
        date: "2022-09-07",
        filename: "PXL_20220907_215329887.jpg",
        video: true
      },
      %{
        label: "Intense grooming",
        date: "2022-09-24",
        filename: "PXL_20220924_174434178.jpg",
        video: true
      },
      %{label: "Hanging with dad", date: "2022-09-29", filename: "IMG_2995.jpg", video: false},
      %{label: "Sunbathing", date: "2022-10-10", filename: "IMG_3012.jpg", video: false},
      %{
        label: "Enjoying a tummy rub",
        date: "2022-12-01",
        filename: "IMG_3120.jpg",
        video: false
      },
      %{label: "Hanging with dad", date: "2022-12-10", filename: "IMG_3131.jpg", video: false},
      %{
        label: "Mid-grooming, 13th birthday",
        date: "2023-01-01",
        filename: "PXL_20230101_161750912.jpg",
        video: true
      },
      %{label: "Hanging with dad", date: "2023-01-01", filename: "IMG_3165.jpg", video: false},
      %{label: "Time for breakfast!", date: "2023-03-05", filename: "IMG_3264.jpg", video: false},
      %{label: "Hanging with dad", date: "2023-03-26", filename: "IMG_3315.jpg", video: false},
      %{
        label: "Cheddar passed the dangle test with flying colors",
        date: "2023-05-12",
        filename: "PXL_20230512_020020439.jpg",
        video: true
      },
      %{label: "Hanging with dad", date: "2023-05-13", filename: "IMG_3535.jpg", video: false},
      %{
        label: "Boop!",
        date: "2023-05-27",
        filename: "PXL_20230527_204610442.jpg",
        video: true
      },
      %{
        label: "Looking regal",
        date: "2023-07-04",
        filename: "PXL_20230704_230302378.jpg",
        video: true
      },
      %{
        label: "Cheddar enjoyed being carried by his humans",
        date: "2023-07-21",
        filename: "PXL_20230721_013350322.jpg",
        video: true
      },
      %{
        label: "Dead bug meow",
        date: "2023-08-01",
        filename: "PXL_20230801_180314602.jpg",
        video: true
      },
      %{label: "Hanging with dad", date: "2023-08-07", filename: "IMG_3731.jpg", video: false},
      %{label: "Hey!", date: "2023-08-09", filename: "PXL_20230809_134819627.jpg", video: true},
      %{
        label: "He had an apartment in an ikea cube shelf that he enjoyed in warmer months",
        date: "2023-09-01",
        filename: "PXL_20230901_160209439.jpg",
        video: true
      },
      %{label: "Bedtime snug", date: "2023-10-03", filename: "IMG_3923.jpg", video: false},
      %{label: "Shoulder cat", date: "2023-10-24", filename: "IMG_3958.jpg", video: false},
      %{
        label: "Shoulder cat",
        date: "2023-10-24",
        filename: "PXL_20231025_011742499.jpg",
        video: true
      },
      %{
        label: "Looking handsome",
        date: "2023-10-30",
        filename: "PXL_20231031_002808320.jpg",
        video: true
      },
      %{
        label: "Coming in for a scritch",
        date: "2023-11-06",
        filename: "PXL_20231106_121208325.jpg",
        video: true
      },
      %{
        label: "Sibling snug, looking serious",
        date: "2023-12-12",
        filename: "PXL_20231212_191642003.jpg",
        video: true
      },
      %{
        label: "Synchronized tongue action",
        date: "2023-12-12",
        filename: "PXL_20231212_191647567_exported_299_1702408740658.jpg",
        video: false
      },
      %{
        label: "Getting down to business",
        date: "2023-12-14",
        filename: "IMG_4064.jpg",
        video: false
      },
      %{
        label: "Double scoop",
        date: "2023-12-17",
        filename: "PXL_20231217_224202264.jpg",
        video: true
      },
      %{label: "Double scoop", date: "2023-12-26", filename: "IMG_4094.jpg", video: false},
      %{
        label: "Enjoying a scritch on his 14th birthday",
        date: "2024-01-01",
        filename: "PXL_20240101_160310504.jpg",
        video: true
      },
      %{label: "Getting a lift", date: "2024-02-08", filename: "IMG_4172.jpg", video: false},
      %{label: "Lounging", date: "2024-03-01", filename: "IMG_4203.jpg", video: false},
      %{
        label: "Morning scene",
        date: "2024-04-06",
        filename: "PXL_20240406_155843772.jpg",
        video: true
      },
      %{label: "Double lap cat", date: "2024-04-12", filename: "IMG_4319.jpg", video: false},
      %{
        label: "Morning scene",
        date: "2024-04-30",
        filename: "PXL_20240430_115631975.jpg",
        video: true
      },
      %{
        label: "Close-up",
        date: "2024-05-01",
        filename: "PXL_20240502_035506973.jpg",
        video: true
      },
      %{label: "Family", date: "2024-05-19", filename: "PXL_20240520_002200924.jpg", video: true},
      %{
        label: "Dinner scene",
        date: "2024-05-24",
        filename: "PXL_20240525_025757675.jpg",
        video: true
      },
      %{
        label: "Cube shelf apartment",
        date: "2024-05-27",
        filename: "PXL_20240527_145830855.jpg",
        video: true
      },
      %{
        label: "Looking handsome",
        date: "2024-05-27",
        filename: "PXL_20240527_153558310.jpg",
        video: true
      },
      %{
        label: "Hey!",
        date: "2024-06-13",
        filename: "PXL_20240613_184512963.jpg",
        video: true
      },
      %{
        label: "Looking fierce",
        date: "2024-06-17",
        filename: "PXL_20240617_231303617.jpg",
        video: true
      },
      %{
        label: "Excited to greet me",
        date: "2024-06-19",
        filename: "PXL_20240619_162758920.jpg",
        video: true
      },
      %{
        label: "Looking handsome",
        date: "2024-07-13",
        filename: "PXL_20240713_151915119.jpg",
        video: true
      },
      %{
        label: "Snoozin'",
        date: "2024-07-16",
        filename: "PXL_20240716_011249612.jpg",
        video: true
      },
      %{
        label: "Looking serious",
        date: "2024-07-22",
        filename: "PXL_20240723_024028374.jpg",
        video: true
      },
      %{
        label: "New seat identified",
        date: "2024-08-24",
        filename: "PXL_20240824_213839447.jpg",
        video: true
      },
      %{label: "Shmoozing", date: "2024-08-26", filename: "IMG_4743.jpg", video: false},
      %{
        label: "One box per cat",
        date: "2024-09-13",
        filename: "PXL_20240913_220545468.jpg",
        video: true
      },
      %{
        label: "Morning scene",
        date: "2024-10-11",
        filename: "PXL_20241011_130340918.jpg",
        video: true
      },
      %{
        label: "Dinner scene",
        date: "2024-10-26",
        filename: "PXL_20241027_031204559.jpg",
        video: true
      },
      %{
        label: "Grooming",
        date: "2024-11-04",
        filename: "PXL_20241104_214920036.jpg",
        video: true
      },
      %{
        label: "Lounging with the fam",
        date: "2024-11-09",
        filename: "IMG_5049.jpg",
        video: false
      },
      %{
        label: "Enjoying a scritch",
        date: "2024-11-26",
        filename: "PXL_20241127_022451029.jpg",
        video: true
      },
      %{label: "Dinner table snuggle", date: "2024-11-30", filename: "IMG_5091.jpg", video: true},
      %{
        label: "Morning scene",
        date: "2024-12-11",
        filename: "PXL_20241211_125639482.jpg",
        video: true
      },
      %{
        label: "Goofing around in packaging",
        date: "2024-12-25",
        filename: "PXL_20241225_155420455.jpg",
        video: true
      },
      %{
        label: "Celebrating his 15th birthday",
        date: "2025-01-01",
        filename: "PXL_20250101_152450786.jpg",
        video: true
      },
      %{
        label: "Looking handsome on his 15th birthday",
        date: "2025-01-01",
        filename: "PXL_20250101_151432570.jpg",
        video: true
      },
      %{
        label: "Looking handsome on his 15th birthday",
        date: "2025-01-01",
        filename: "PXL_20250101_151821597.jpg",
        video: true
      },
      %{
        label: "Morning scene",
        date: "2025-01-23",
        filename: "PXL_20250123_130356930.jpg",
        video: true
      },
      %{
        label: "Dinner's late",
        date: "2025-02-01",
        filename: "PXL_20250202_031906428.jpg",
        video: true
      },
      %{label: "Dinner table snuggle", date: "2025-02-05", filename: "IMG_5229.jpg", video: true},
      %{
        label: "Evening scene",
        date: "2025-02-10",
        filename: "PXL_20250211_025141681.jpg",
        video: true
      },
      %{
        label: "Fingie inspection",
        date: "2025-02-22",
        filename: "PXL_20250223_035938379.jpg",
        video: true
      },
      %{
        label: "Bedtime scene",
        date: "2025-02-22",
        filename: "PXL_20250223_040004045.jpg",
        video: true
      },
      %{label: "Dinner table snuggle", date: "2025-02-23", filename: "IMG_5274.jpg", video: true},
      %{
        label: "Enjoying a scritch",
        date: "2025-02-27",
        filename: "PXL_20250227_131849803.jpg",
        video: true
      },
      %{
        label: "Hey-Service is slow!",
        date: "2025-03-21",
        filename: "PXL_20250321_134144932.jpg",
        video: true
      },
      %{
        label: "Morning scene",
        date: "2025-04-29",
        filename: "PXL_20250429_123544011.jpg",
        video: true
      },
      %{
        label: "Guard cats hard at work",
        date: "2025-06-14",
        filename: "PXL_20250614_200134550.jpg",
        video: true
      },
      %{
        label: "Embracing on the couch",
        date: "2025-06-19",
        filename: "IMG_5708.jpg",
        video: true
      },
      %{label: "Blissed out snoozer", date: "2025-06-28", filename: "IMG_5741.jpg", video: true},
      %{
        label: "A typical evening scene",
        date: "2025-07-29",
        filename: "IMG_5866.jpg",
        video: true
      },
      %{
        label: "Hanging with dad",
        date: "2025-08-03",
        filename: "PXL_20250803_192007810.jpg",
        video: true
      },
      %{
        label: "Getting massaged into another state of existence",
        date: "2025-08-17",
        filename: "IMG_5913.jpg",
        video: true
      },
      %{label: "Dead bug snug", date: "2025-10-04", filename: "IMG_5999.jpg", video: true},
      %{label: "Double scoop", date: "2025-10-29", filename: "IMG_6059.jpg", video: true},
      %{
        label: "Bedtime excitement",
        date: "2025-11-27",
        filename: "PXL_20251128_045359218.jpg",
        video: true
      },
      %{
        label: "Morning haze",
        date: "2025-12-15",
        filename: "PXL_20251215_122606969.jpg",
        video: true
      },
      %{
        label: "Pleading for dinner",
        date: "2025-12-19",
        filename: "PXL_20251220_023240881.jpg",
        video: true
      },
      %{
        label: "Looking handsome on his 16th birthday",
        date: "2026-01-01",
        filename: "PXL_20260101_144649709.jpg",
        video: true
      },
      %{
        label: "Cardboard boxes were forever an interest",
        date: "2026-01-07",
        filename: "PXL_20260107_232010050.jpg",
        video: true
      },
      %{label: "A perfect box", date: "2026-01-17", filename: "IMG_6223.jpg", video: true},
      %{
        label: "Bedtime excitement",
        date: "2026-01-26",
        filename: "PXL_20260127_040633209.jpg",
        video: true
      },
      %{label: "Double scoop", date: "2026-02-03", filename: "IMG_6259.jpg", video: true},
      %{label: "Morning scene", date: "2026-02-08", filename: "IMG_6274.jpg", video: true},
      %{label: "Enjoying a belly rub", date: "2026-02-28", filename: "IMG_6326.jpg", video: true},
      %{
        label: "Bedtime cuddle",
        date: "2026-03-17",
        filename: "PXL_20260317_030543244.jpg",
        video: true
      },
      %{
        label: "Snugglin'",
        date: "2026-03-22",
        filename: "PXL_20260322_222239949.jpg",
        video: true
      },
      %{
        label: "Shmoozin'",
        date: "2026-04-19",
        filename: "PXL_20260420_001211114.jpg",
        video: false
      },
      %{
        label: "Hanging with the fam",
        date: "2026-06-04",
        filename: "IMG_6641.jpg",
        video: false
      },

      # cat snugs
      %{
        label: "Snuggly siblings, shortly after adoption",
        date: "2010-02-24",
        filename: "2010-02-24-9.jpg",
        video: false
      },
      %{
        label: "Sibling love",
        date: "2010-04-05",
        filename: "2010-04-05.jpg",
        video: false
      },
      %{label: "Sibling love", date: "2010-04-24", filename: "2010-04-24.jpg", video: false},
      %{
        label: "Sibling love",
        date: "2010-09-18",
        filename: "IMG_0588.jpg",
        video: false
      },
      %{label: "Sibling love", date: "2011-02-17", filename: "IMG_0869.jpg", video: false},
      %{label: "Sibling love", date: "2011-02-24", filename: "IMG_0885.jpg", video: false},
      %{label: "Sibling love", date: "2011-06-25", filename: "IMG_1044.jpg", video: false},
      %{label: "Sibling love", date: "2014-02-22", filename: "IMGP2200.jpg", video: false},
      %{
        label: "Sibling love",
        date: "2016-03-19",
        filename: "IMG_20160319_143308.jpg",
        video: false
      },
      %{
        label: "Sibling love",
        date: "2016-03-20",
        filename: "IMG_20160320_154141.jpg",
        video: false
      },
      %{
        label: "Sibling love",
        date: "2016-10-23",
        filename: "IMG_20161023_233706.jpg",
        video: false
      },
      %{label: "Sibling snuggles", date: "2016-11-26", filename: "2016-11-26.jpg", video: false},
      %{
        label: "Sibling snuggles",
        date: "2016-11-26",
        filename: "IMG_20161126_131957.jpg",
        video: false
      },
      %{
        label: "Sibling snuggles",
        date: "2016-11-26",
        filename: "2016_11_26_131018.gif",
        video: false
      },
      %{
        label: "Sibling snuggles",
        date: "2016-11-26",
        filename: "2016_11_26_132646.gif",
        video: false
      },
      %{
        label: "Sibling love",
        date: "2017-01-22",
        filename: "IMG_20170122_160500.jpg",
        video: false
      },
      %{
        label: "Sibling love",
        date: "2017-03-19",
        filename: "IMG_20170319_152726.jpg",
        video: false
      },
      %{
        label: "Sibling love",
        date: "2017-05-14",
        filename: "IMG_20170514_150307.jpg",
        video: false
      },
      %{
        label: "Sibling love",
        date: "2017-05-14",
        filename: "IMG_20170514_150604.jpg",
        video: false
      },
      %{
        label: "Sibling love",
        date: "2017-06-18",
        filename: "IMG_20170618_135521.jpg",
        video: false
      },
      %{label: "Grooming session", date: "2017-07-16", filename: "2017-07-16.gif", video: false},
      %{
        label: "Sibling love",
        date: "2017-09-03",
        filename: "IMG_20170903_153231.jpg",
        video: false
      },
      %{
        label: "Sibling love",
        date: "2018-01-14",
        filename: "IMG_20180114_150433.jpg",
        video: false
      },
      %{
        label: "Sibling love",
        date: "2018-01-14",
        filename: "IMG_20180114_151521.jpg",
        video: false
      },
      %{
        label: "Snoozing in dad's leg crook",
        date: "2018-04-29",
        filename: "IMG_20180429_014143.jpg",
        video: false
      },
      %{
        label: "Sibling love",
        date: "2018-11-17",
        filename: "IMG_20181117_200729.jpg",
        video: false
      },
      %{
        label: "Sibling love",
        date: "2018-12-18",
        filename: "IMG_20181218_161442.jpg",
        video: false
      },
      %{
        label: "Sibling love",
        date: "2019-03-31",
        filename: "MVIMG_20190331_123203.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2019-03-31",
        filename: "MVIMG_20190331_124911.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2019-05-12",
        filename: "MVIMG_20190512_182753.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2020-04-14",
        filename: "MVIMG_20200414_145819.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2020-04-14",
        filename: "MVIMG_20200414_174408.jpg",
        video: true
      },
      %{label: "Sibling love", date: "2020-05-12", filename: "IMG_0053.jpg", video: true},
      %{
        label: "Sibling love",
        date: "2020-05-15",
        filename: "MVIMG_20200515_130605.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2020-05-20",
        filename: "MVIMG_20200520_105641.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2020-05-25",
        filename: "MVIMG_20200525_184831.jpg",
        video: true
      },
      %{label: "Sibling love", date: "2020-07-12", filename: "IMG_0280.jpg", video: true},
      %{
        label: "Sibling love",
        date: "2020-10-07",
        filename: "PXL_20201007_184949703.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2020-10-08",
        filename: "PXL_20201008_152246332.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2020-10-12",
        filename: "PXL_20201012_143011156.jpg",
        video: true
      },
      %{label: "Sibling love", date: "2020-11-04", filename: "IMG_0794.jpg", video: true},
      %{
        label: "Sibling love",
        date: "2020-12-05",
        filename: "PXL_20201205_180611556.jpg",
        video: true
      },
      %{label: "Sibling love", date: "2020-12-20", filename: "IMG_0936.jpg", video: true},
      %{
        label: "Sibling love",
        date: "2020-12-26",
        filename: "PXL_20201226_185926898.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2020-12-29",
        filename: "PXL_20201229_195710211.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2021-02-02",
        filename: "PXL_20210202_181359374.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2021-08-31",
        filename: "PXL_20210831_160906018.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2021-10-13",
        filename: "PXL_20211013_154132913.jpg",
        video: true
      },
      %{label: "Sibling love", date: "2021-11-01", filename: "IMG_1977.jpg", video: false},
      %{
        label: "Sibling love",
        date: "2021-11-26",
        filename: "PXL_20211126_192210753.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2021-12-04",
        filename: "PXL_20211204_192025785.jpg",
        video: true
      },
      %{label: "Sibling love", date: "2022-01-18", filename: "IMG_2196.jpg", video: false},
      %{
        label: "Sibling love",
        date: "2022-01-19",
        filename: "PXL_20220119_191533455.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2022-01-26",
        filename: "PXL_20220126_180210072.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2022-04-02",
        filename: "PXL_20220402_221711260.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2022-04-30",
        filename: "PXL_20220430_175735855.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2022-06-19",
        filename: "PXL_20220619_180738528.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2023-01-05",
        filename: "PXL_20230105_174735640.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2023-03-23",
        filename: "PXL_20230323_162354791.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2023-03-28",
        filename: "PXL_20230328_181031129.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2023-10-02",
        filename: "PXL_20231002_152306213.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2023-10-20",
        filename: "PXL_20231020_155249573.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2023-10-22",
        filename: "PXL_20231022_193148086.jpg",
        video: true
      },
      %{label: "Sibling love", date: "2023-11-03", filename: "IMG_3979.jpg", video: false},
      %{
        label: "Sibling love",
        date: "2023-12-03",
        filename: "PXL_20231203_003240242.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2023-12-21",
        filename: "PXL_20231221_231430118.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2024-01-09",
        filename: "PXL_20240109_162913950.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2024-02-29",
        filename: "PXL_20240229_162031235.jpg",
        video: true
      },
      %{label: "Sibling love", date: "2024-03-01", filename: "IMG_4205.jpg", video: false},
      %{
        label: "Sibling love",
        date: "2024-03-13",
        filename: "PXL_20240313_181400865.jpg",
        video: true
      },
      %{label: "Sibling love", date: "2024-04-12", filename: "IMG_4316.jpg", video: false},
      %{
        label: "Sibling love",
        date: "2024-11-14",
        filename: "PXL_20241114_223645495.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2024-11-14",
        filename: "PXL_20241114_223924183.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2024-12-11",
        filename: "PXL_20241211_222756909.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2024-12-21",
        filename: "PXL_20241221_184132481.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2024-12-25",
        filename: "PXL_20241225_210818609.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2024-12-25",
        filename: "PXL_20241225_233441310.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2024-12-27",
        filename: "PXL_20241227_015727728.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2024-12-30",
        filename: "PXL_20241230_000914484.jpg",
        video: true
      },
      %{
        label: "Sibling grooming",
        date: "2025-01-01",
        filename: "PXL_20250101_155419943.jpg",
        video: true
      },
      %{
        label: "Sibling grooming",
        date: "2025-01-01",
        filename: "PXL_20250101_155443139.jpg",
        video: true
      },
      %{
        label: "Sibling grooming",
        date: "2025-01-01",
        filename: "PXL_20250101_155459751.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2025-01-02",
        filename: "PXL_20250102_190744673.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2025-01-02",
        filename: "PXL_20250102_215722568.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2025-01-03",
        filename: "PXL_20250103_213325126.jpg",
        video: true
      },
      %{label: "Sibling love", date: "2025-01-04", filename: "IMG_5163.jpg", video: true},
      %{
        label: "Sibling love",
        date: "2025-01-06",
        filename: "PXL_20250106_010047866.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2025-01-06",
        filename: "PXL_20250106_010922112.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2025-01-11",
        filename: "PXL_20250111_171652076.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2025-01-13",
        filename: "PXL_20250113_210245005.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2025-01-20",
        filename: "PXL_20250120_173703933.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2025-01-23",
        filename: "PXL_20250123_214228161.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2025-01-26",
        filename: "PXL_20250126_000815845.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2025-01-26",
        filename: "PXL_20250126_003043056.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2025-02-19",
        filename: "PXL_20250219_155202254.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2025-03-07",
        filename: "PXL_20250307_181652852.jpg",
        video: true
      },
      %{label: "Sibling love", date: "2025-05-23", filename: "IMG_5627.jpg", video: true},
      %{
        label: "Sibling love",
        date: "2025-05-23",
        filename: "PXL_20250523_174012943.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2025-10-10",
        filename: "PXL_20251010_195219842.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2025-10-10",
        filename: "PXL_20251010_213245103.jpg",
        video: true
      },
      %{label: "Sibling love", date: "2025-10-18", filename: "IMG_6031.jpg", video: true},
      %{label: "Sibling love", date: "2025-10-18", filename: "IMG_6036.jpg", video: true},
      %{
        label: "Sibling love",
        date: "2025-10-21",
        filename: "PXL_20251021_195055962.jpg",
        video: true
      },
      %{label: "Sibling love", date: "2025-11-08", filename: "IMG_6084.jpg", video: true},
      %{
        label: "Sibling love",
        date: "2025-11-19",
        filename: "PXL_20251119_211850233.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2025-11-19",
        filename: "PXL_20251119_231827327.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2025-11-21",
        filename: "PXL_20251121_195225090.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2025-11-24",
        filename: "PXL_20251124_172735860.jpg",
        video: true
      },
      %{label: "Sibling love", date: "2025-12-08", filename: "2025-12-08.jpg", video: false},
      %{
        label: "Sibling love",
        date: "2025-12-17",
        filename: "PXL_20251217_194029601.jpg",
        video: true
      },
      %{label: "Sibling love", date: "2025-12-22", filename: "2025-12-22.jpg", video: false},
      %{
        label: "Sibling love",
        date: "2025-12-23",
        filename: "PXL_20251223_202704217.jpg",
        video: true
      },
      %{label: "Sibling love", date: "2025-12-27", filename: "IMG_6202.jpg", video: true},
      %{label: "Sibling love", date: "2026-02-04", filename: "IMG_6264.jpg", video: true},
      %{label: "Sibling love", date: "2026-03-01", filename: "IMG_6334.jpg", video: true},
      %{
        label: "Sibling love",
        date: "2026-03-30",
        filename: "PXL_20260330_165544428.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2026-04-08",
        filename: "PXL_20260408_215658138.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2026-04-09",
        filename: "PXL_20260409_161439345.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2026-04-19",
        filename: "PXL_20260419_204001262.jpg",
        video: true
      },
      %{
        label: "Sibling love",
        date: "2026-05-23",
        filename: "PXL_20260523_232251675.jpg",
        video: true
      },

      # people snugs
      %{
        label: "The finest lap cat",
        date: "2016-03-27",
        filename: "IMG_20160327_193457.jpg",
        video: false
      },
      %{
        label: "The finest lap cat",
        date: "2016-04-28",
        filename: "IMG_20160428_222303.jpg",
        video: false
      },
      %{
        label: "The finest lap cat",
        date: "2016-10-23",
        filename: "IMG_20161023_161244.jpg",
        video: false
      },
      %{
        label: "The finest lap cat",
        date: "2016-10-29",
        filename: "IMG_20161029_143835.jpg",
        video: false
      },
      %{
        label: "The finest lap cat",
        date: "2016-12-15",
        filename: "IMG_20161215_112625.jpg",
        video: false
      },
      %{
        label: "Double lap cat",
        date: "2018-12-09",
        filename: "IMG_20181209_152505.jpg",
        video: false
      },
      %{
        label: "Double lap cat",
        date: "2019-12-29",
        filename: "MVIMG_20191229_152148.jpg",
        video: true
      },
      %{
        label: "The finest lap cat",
        date: "2020-03-27",
        filename: "MVIMG_20200327_160938.jpg",
        video: true
      },
      %{label: "Enjoying a rub", date: "2020-08-07", filename: "IMG_0355.jpg", video: true},
      %{
        label: "Double lap cat",
        date: "2020-11-03",
        filename: "PXL_20201103_195955805.jpg",
        video: true
      },
      %{label: "Double lap cat", date: "2020-11-14", filename: "IMG_0827.jpg", video: true},
      %{label: "Double lap cat", date: "2020-11-21", filename: "IMG_0847.jpg", video: true},
      %{
        label: "The finest lap cat",
        date: "2020-11-27",
        filename: "PXL_20201127_002630772.jpg",
        video: true
      },
      %{
        label: "The finest lap cat",
        date: "2020-12-25",
        filename: "PXL_20201225_170305534.jpg",
        video: true
      },
      %{
        label: "The finest lap cat",
        date: "2021-01-16",
        filename: "PXL_20210116_200310347.jpg",
        video: true
      },
      %{label: "Bean rub", date: "2021-03-14", filename: "IMG_1178.jpg", video: true},
      %{label: "Double lap cat", date: "2021-03-18", filename: "IMG_1187.jpg", video: true},
      %{
        label: "The finest lap cat",
        date: "2021-07-27",
        filename: "PXL_20210727_004916033.jpg",
        video: true
      },
      %{
        label: "The finest lap cat",
        date: "2021-10-17",
        filename: "PXL_20211017_204048923.jpg",
        video: true
      },
      %{label: "The finest lap cat", date: "2021-12-22", filename: "IMG_2111.jpg", video: false},
      %{label: "One cat per leg", date: "2022-01-19", filename: "IMG_2200.jpg", video: false},
      %{
        label: "Ched's favorite place",
        date: "2022-01-19",
        filename: "IMG_2208.jpg",
        video: false
      },
      %{
        label: "The finest lap cat",
        date: "2022-01-30",
        filename: "PXL_20220130_183750054.jpg",
        video: true
      },
      %{label: "Double lap cat", date: "2022-03-16", filename: "IMG_2398.jpg", video: false},
      %{
        label: "Double lap cat",
        date: "2022-03-20",
        filename: "PXL_20220320_195559399.jpg",
        video: true
      },
      %{
        label: "The finest lap cat",
        date: "2022-04-28",
        filename: "PXL_20220429_005114823.jpg",
        video: true
      },
      %{label: "Double lap cat", date: "2022-10-29", filename: "IMG_3062.jpg", video: false},
      %{
        label: "The finest lap cat",
        date: "2023-01-01",
        filename: "PXL_20230101_201923744.jpg",
        video: true
      },
      %{
        label: "The finest lap cat",
        date: "2023-09-15",
        filename: "PXL_20230915_230054830.jpg",
        video: true
      },
      %{
        label: "The finest lap cat",
        date: "2023-10-17",
        filename: "PXL_20231017_190321029.jpg",
        video: true
      },
      %{
        label: "The finest lap cat",
        date: "2023-12-01",
        filename: "PXL_20231201_203451592.jpg",
        video: true
      },
      %{
        label: "The finest lap cat",
        date: "2023-12-08",
        filename: "PXL_20231208_034205291.jpg",
        video: true
      },
      %{
        label: "Double lap cat",
        date: "2023-12-20",
        filename: "PXL_20231220_212701926.jpg",
        video: true
      },
      %{
        label: "Double lap cat",
        date: "2023-12-28",
        filename: "PXL_20231228_010104927.jpg",
        video: true
      },
      %{
        label: "The finest lap cat",
        date: "2024-01-18",
        filename: "PXL_20240118_021739264.jpg",
        video: true
      },
      %{
        label: "Double lap cat",
        date: "2024-01-20",
        filename: "PXL_20240120_021903765.jpg",
        video: true
      },
      %{
        label: "Double lap cat",
        date: "2024-01-20",
        filename: "PXL_20240120_022758124.jpg",
        video: true
      },
      %{
        label: "The finest lap cat",
        date: "2024-02-10",
        filename: "PXL_20240210_224350841.jpg",
        video: true
      },
      %{
        label: "The finest lap cat",
        date: "2024-11-10",
        filename: "PXL_20241110_002752029.jpg",
        video: true
      },
      %{
        label: "Hanging on dad",
        date: "2025-04-13",
        filename: "PXL_20250413_235411405.jpg",
        video: true
      },
      %{
        label: "Double lap cat",
        date: "2025-05-17",
        filename: "PXL_20250517_142926814.jpg",
        video: true
      },
      %{
        label: "The finest lap cat",
        date: "2025-05-31",
        filename: "PXL_20250531_175712295.jpg",
        video: true
      },
      %{
        label: "Double lap cat",
        date: "2026-01-10",
        filename: "PXL_20260110_184236531.jpg",
        video: true
      },
      %{
        label: "Double lap cat",
        date: "2026-02-15",
        filename: "PXL_20260215_021619773.jpg",
        video: true
      },
      %{
        label: "The finest lap cat",
        date: "2026-02-21",
        filename: "PXL_20260221_161904335.jpg",
        video: true
      },

      # antics
      %{label: "Caught in the act", date: "2010-05-07", filename: "2010-05-07.jpg", video: false},
      %{label: "Kitten wrestling", date: "2010-07-28", filename: "IMG_0200.jpg", video: false},
      %{label: "Toilet paper mayhem", date: "2010-10-17", filename: "IMG_0667.jpg", video: false},
      %{label: "Entropy at work", date: "2011-02-02", filename: "IMG_0816.jpg", video: false},
      %{
        label:
          "One time we made cheddar chase a toy up and down the stairs until he had to stop to pant",
        date: "2011-04-11",
        filename: "2011-04-11.gif",
        video: false
      },
      %{
        label: "Antics on the shelf",
        date: "2011-08-05",
        filename: "IMG_20110805_170932.jpg",
        video: false
      },
      %{
        label: "Antics on the shelf",
        date: "2011-08-08",
        filename: "IMG_20110808_181425.jpg",
        video: false
      },
      %{
        label:
          "Cheddar never properly learned how to retract his claws and several times I had to save him. He always looked silly and helpless when it happened.",
        date: "2011-09-04",
        filename: "IMG_20110904_094916.jpg",
        video: false
      },
      %{
        label: "For a period of time Cheddar would sit on the tops of open doors.",
        date: "2012-04-07",
        filename: "IMG_20120407_193553.jpg",
        video: false
      },
      %{
        label: "For a period of time Cheddar would sit on the tops of open doors.",
        date: "2012-11-29",
        filename: "IMG_20121129_062235.jpg",
        video: false
      },
      %{label: "Airborne", date: "2013-09-07", filename: "2013-09-07.jpg", video: false},
      %{
        label: "Laundry inspector",
        date: "2014-12-29",
        filename: "IMG_20141229_225345.jpg",
        video: false
      },
      %{
        label: "Disappointed about the tardy food service",
        date: "2016-02-28",
        filename: "IMG_20160228_093303.jpg",
        video: false
      },
      %{label: "Water thief", date: "2016-11-06", filename: "2016-11-06.jpg", video: false},
      %{label: "Boing!", date: "2016-12-18", filename: "2016_12_18_201422.gif", video: false},
      %{label: "Water thief", date: "2017-09-15", filename: "2017-09-15.jpg", video: false},
      %{
        label: "Breaking into the basement",
        date: "2019-05-03",
        filename: "MVIMG_20190503_210536.jpg",
        video: true
      },
      %{
        label: "Hopped up on cat nip",
        date: "2020-01-26",
        filename: "MVIMG_20200126_145813.jpg",
        video: true
      },
      %{
        label: "Water thief",
        date: "2020-07-02",
        filename: "MVIMG_20200702_122328.jpg",
        video: true
      },
      %{
        label: "Trying to escape in the market basket",
        date: "2020-08-16",
        filename: "IMG_0400.jpg",
        video: true
      },
      %{
        label: "One of those times when he needed assistance unhooking",
        date: "2020-08-21",
        filename: "MVIMG_20200821_134125.jpg",
        video: true
      },
      %{label: "Boop", date: "2021-01-01", filename: "PXL_20210101_173025729.jpg", video: true},
      %{
        label: "Hopped up on cat nip",
        date: "2021-01-06",
        filename: "PXL_20210107_040459603.jpg",
        video: true
      },
      %{
        label: "Butter thief",
        date: "2021-08-31",
        filename: "PXL_20210831_180647355.jpg",
        video: true
      },
      %{
        label: "Hopped up on cat nip",
        date: "2022-12-25",
        filename: "PXL_20221225_153717312.jpg",
        video: true
      },
      %{label: "Boop", date: "2023-11-06", filename: "PXL_20231106_121224370.jpg", video: true},
      %{
        label:
          "Cheddar loved to perforate plastic of specific thickness, including trash bag handles and shower curtain liners.",
        date: "2024-02-28",
        filename: "PXL_20240228_232736347.jpg",
        video: true
      },
      %{label: "Boop", date: "2024-05-19", filename: "PXL_20240520_001641496.jpg", video: true},
      %{label: "Boop", date: "2024-05-19", filename: "PXL_20240520_001706052.jpg", video: true},
      %{
        label: "Close-up",
        date: "2024-07-05",
        filename: "PXL_20240706_033448048.jpg",
        video: true
      },
      %{
        label: "Yoga inspector",
        date: "2024-11-20",
        filename: "PXL_20241120_235919050.jpg",
        video: true
      },
      %{
        label: "Close-up",
        date: "2025-01-01",
        filename: "PXL_20250101_151606377.jpg",
        video: true
      },
      %{
        label:
          "For a brief period, Cheddar would occasionally jump in the laundry hamper. He couldn't figure out how to get out and would meow until a human rescued him.",
        date: "2025-04-27",
        filename: "PXL_20250427_000917547.jpg",
        video: true
      },
      %{
        label: "Assisting with seedlings",
        date: "2026-05-13",
        filename: "PXL_20260513_015129326.jpg",
        video: true
      }
    ]
  end

  defp gallery_context() do
    entries =
      entries()
      |> Enum.map(fn entry ->
        video_src = asset_src(entry, :video)

        entry =
          entry
          |> Map.take([:date, :label])
          |> Map.put(:original, asset_src(entry, :original))
          |> Map.put(:thumb1x, asset_src(entry, :thumb1x))
          |> Map.put(:thumb2x, asset_src(entry, :thumb2x))
          |> Map.put(:thumb4x, asset_src(entry, :thumb4x))
          |> Map.put(:web, asset_src(entry, :web))

        if video_src != nil,
          do: Map.put(entry, :video, video_src),
          else: entry
      end)

    JSON.encode!(%{
      entries: entries
    })
  end

  defp gallery_grid_element(src, opts \\ []) do
    assigns = %{
      opts: Keyword.put(opts, :class, "gallery-grid-item gallery-opener"),
      src: src
    }

    ~H"""
    <div class="gallery-item">
      {inline_gallery_img_element(@src, @opts)}
    </div>
    """
  end

  defp favorites() do
    [
      "2010-02-24-9.jpg",
      "2010-02-26-07.jpg",
      "2010-05-07.jpg",
      "2011-04-11.gif",
      "IMG_20111217_233927.jpg",
      "2013-08-08.jpg",
      "IMG_20160228_093303.jpg",
      "MVIMG_20190503_210536.jpg",
      "IMG_3574.jpg",
      "IMG_0208.jpg",
      "IMG_0506.jpg",
      "IMG_1275.jpg",
      "PXL_20210831_180647355.jpg",
      "PXL_20230512_020020439.jpg",
      "PXL_20230704_230302378.jpg",
      "IMG_4064.jpg",
      "PXL_20240120_022758124.jpg",
      "PXL_20250123_130356930.jpg"
    ]
  end

  defp asset_src(entry, variation) do
    {filename, extension} = parse_filename(entry)

    cond do
      entry.video == false and variation == :video ->
        nil

      variation == :video ->
        asset_uri("#{filename}.mp4")

      variation == :web and extension == "gif" ->
        asset_uri("#{filename}.gif")

      variation == :web ->
        asset_uri("#{filename}_#{variation}.avif")

      variation == :thumb1x ->
        asset_uri("#{filename}_thumb_1x.avif")

      variation == :thumb2x ->
        asset_uri("#{filename}_thumb_2x.avif")

      variation == :thumb4x ->
        asset_uri("#{filename}_thumb_4x.avif")

      true ->
        asset_uri("#{filename}_#{variation}.#{extension}")
    end
  end

  defp asset_srcset(entry) do
    [
      {:thumb2x, "2x"},
      {:thumb4x, "4x"}
    ]
    |> Enum.map(&"#{asset_src(entry, elem(&1, 0))} #{elem(&1, 1)}")
    |> Enum.join(",\n")
  end

  defp asset_uri(filename),
    do: "https://assets.gabrielmiller.org/cheddar/#{filename}"

  defp inline_gallery_img_element(src, opts) do
    class = Keyword.get(opts, :class, "gallery-item gallery-opener")
    obscure_navigation = Keyword.get(opts, :obscure_navigation, true)

    entry = Enum.find(entries(), &(src == &1.filename))

    data_attributes =
      if obscure_navigation,
        do: %{"data-obscure-navigation" => "true"},
        else: %{}

    assigns = %{
      class: class,
      src: asset_src(entry, :thumb1x),
      srcset: asset_srcset(entry),
      data_attributes: data_attributes
    }

    ~H"""
    <button {@data_attributes} class={@class} type="button">
      <img loading="lazy" src={@src} srcset={@srcset} {@data_attributes} />
    </button>
    """
  end

  defp grouped_entries() do
    section_starts = %{
      "2010-02-24-9.jpg" => 1,
      "IMG_20160327_193457.jpg" => 2,
      "2010-05-07.jpg" => 3
    }

    entries()
    |> Enum.reduce(
      {%{
         0 => [],
         1 => [],
         2 => [],
         3 => []
       }, 0},
      fn entry, {acc, group} ->
        header = Map.get(section_starts, entry.filename)

        group =
          if header == nil,
            do: group,
            else: header

        entries = Map.get(acc, group, [])
        updated_entries = entries ++ [entry.filename]
        {Map.put(acc, group, updated_entries), group}
      end
    )
    |> elem(0)
  end

  defp gallery_group_label(0), do: "General"
  defp gallery_group_label(1), do: "Sibling Love"
  defp gallery_group_label(2), do: "The Finest Lap Cat"
  defp gallery_group_label(3), do: "Antics"

  defp gallery_group_id(0), do: "gallery-extended-general"
  defp gallery_group_id(1), do: "gallery-extended-sibling-love"
  defp gallery_group_id(2), do: "gallery-extended-lap-cat"
  defp gallery_group_id(3), do: "gallery-extended-antics"

  defp id(:memorial), do: "memorial"
  defp id(:being_cheddars_human), do: "being-cheddars-human"
  defp id(:childhood), do: "childhood"
  defp id(:adulthood), do: "adulthood"
  defp id(:super_senior_years), do: "super-senior-years"
  defp id(:gallery), do: "gallery"
  defp id(:gallery_gabes_favorites), do: "gallery-gabes-favorites"
  defp id(:gallery_full_collection), do: "gallery-full-collection"

  defp parse_filename(%{filename: filename}) do
    file_parts = String.split(filename, ".")
    parts_length = length(file_parts)

    name =
      file_parts
      |> List.delete_at(parts_length - 1)
      |> Enum.join(".")

    extension = List.last(file_parts)

    {name, extension}
  end
end
