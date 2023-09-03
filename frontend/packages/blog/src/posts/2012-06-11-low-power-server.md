---
date: "2012-06-11"
slug: "low-power-server"
tags: ["hardware", "homelab"]
title: "Low Power Server"
---

I recently picked up a new computer to run as a headless web and file server 24/7. My main criteria was it must be x86 in order to run commonly available programs and it must be low power. After a fair amount of research I came upon a good fit. The motherboard is created by Intel: the DN2800MT. It uses a processor marketed toward mobile devices, the Atom N2800, and a low power chipset, NM10. The board is the newer Cedar trail generation successor to Intel's notoriously low power 945GSE chipset. I coupled it with a Samsung 830 solid state drive and a high efficiency AC/DC power adapter(Meanwell's GS40). In regards to power draw, the setup idles at 9 to 10 watts according to my Killawatt. I haven't done extensive power testing on the unit, however I have to say I am very happy with its performance thus far.

It's silent and has an extremely short bios boot time. It consistently loads too fast for me to read the boot screen at all. I threw a MySQL database on it and am running a number of small applications with no problems. The ultimate purpose of this machine is learning web development. Perhaps I'll post some benchmarks another day.

A few notes:

The box is running Archlinux and has led to a lot of playing with ssh and networking.

For remote filesystem mounting I found SSHFS to be much more convenient to setup than NFS or SAMBA. The installation was extremely simple; the only server-end requirement was to install SSHFS. On the client end, on linux, mounting is as simple as running a mount command with the specified username and port. On windows mounting with a program called Win-SSHFS.

Comparisons:

I have an older low power computer that I used several years ago that I acquired through a British company called Aleutia that rebadges embedded Linux systems. The model I had was an Aleutia E3, which I believe was a rebadged eBox 3300. There are several notable differences between my current system and that one, but one must note the large time difference between the technologies. First and foremost the current system is actually 64 bit. Secondly, it has some amount of expansion, hosting up to 3 SATA devices, unlike the single IDE port on the Aleutia and up to 4GB of ram instead of the soldered 512mb on the Aleutia. One must note, however, that there are several years of difference between the two architectures. Both are passively cooled; there is no need for a fan.

DN2800MT:
 * Pro: 64 bit
 * Pro: Small amount of expansion possible
 * Pro: Gigabit ethernet
 * Pro: 3 year warranty
 * Pro: Manufactured by Intel
 * Pro: + SATA ports
 * Pro: 4x USB 2.0 ports, DVI-D, and HDMI
 * Con: - Higher power use than Aleutia E3
 * Misc: Mini ITX

Aleutia E3:
 * Pro: x86
 * Pro: Small form factor(Pico-ITX I believe?)
 * Con: 10/100 ethernet
 * Con: Unknown manufacturer. I'm nearly positive getting any support would be a hairpulling experience.
 * Con: Single IDE port and Compact Flash port

After looking through this list one might wonder why I didn't reuse this system for my web and fileserver. The main reason was storage and memory. I wanted to be able to run a fairly large amount of memory(4GB versus 512mb) and a modern speed SSD. The difference in storage speed is almost night and day; my old CF disk was rated for about 40MB read and write while my Samsung 830 is rated closer to 375MB read and write(bottlenecked by SATA2 ports).

More another day!