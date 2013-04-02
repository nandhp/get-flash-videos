# Part of get-flash-videos. See get_flash_videos for copyright.
package FlashVideo::Site::Vk;

use strict;
use FlashVideo::Utils;
use HTML::Entities;

our $VERSION = '0.01';
sub Version() { $VERSION; }

sub find_video {
  my ($self, $browser, $embed_url) = @_;
  my $new_embed_url = "";
  my $title = "";
  my $host = "";
  my $uid = "";
  my $vtag = "";
  my $url = "";
  my $reget = 0;

  $new_embed_url = decode_entities($embed_url);

  # if the URL contains undecoded HTML entities, we have the wrong URL
  # and need to get proper one
  if ($embed_url != $new_embed_url) {
    info ("URI with encoded entities... re-GETing");
    $embed_url = $new_embed_url;
    $reget = 1;
  }

  # vkontakte.ru is the same page as vk.com, but it redirects to login (?)
  if ($embed_url =~ /http:\/\/vkontakte.ru\//) {
    $embed_url =~ s/http:\/\/vkontakte.ru\//http:\/\/vk.com\//;
    $reget = 1;
  }

  # in either of case above let's get the page again with changed URL
  if ($reget) {
    $browser->get($embed_url);
  }
  debug ("URI: " . $embed_url);
 
  if ($browser->content =~ /\s*var video_title = '([^']+)';/) {
    $title = $1;
    debug ("Title: '" . $title . "'");
  }

  return unless ($browser->content =~ /\s*var video_host = '([^']+)';/);
  $host = $1;
  debug ("Host: '" . $host . "'");

  return unless ($browser->content =~ /\s*var video_uid = '([^']+)';/);
  $uid = $1; 
  debug ("UID: '" . $uid . "'");

  return unless ($browser->content =~ /\s*var video_vtag = '([^']+)';/);
  $vtag = $1;

  $url = $host . "u" . $uid . "/videos/" . $vtag . ".360.mp4";
  debug ("URL: '" . $url . "'");
  return $url, title_to_filename($title, "mp4");
}

1;
