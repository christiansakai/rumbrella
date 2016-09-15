/**
 * Class representing the video player.
 */
class Player {

  /**
   * Create a player object in the DOM.
   *
   * @param {string} domId the dom ID where this player will be appended.
   * @param {string} playerId the player ID from Youtube.
   * @param {function} onReady a callback function to be called whenever the player is ready.
   */
  constructor(domId, playerId, onReady) {
    window.onYouTubeIframeAPIReady = () => {
      this.onIframeReady(domId, playerId, onReady);
    };

    let youtubeScriptTag = document.createElement("script");
    youtubeScriptTag.src = "//www.youtube.com/iframe_api";
    document.head.appendChild(youtubeScriptTag);
  }

  /**
   * A callback function to be called when the
   * player iframe is ready.
   *
   * @param {string} domId the dom ID where this player will be appended.
   * @param {string} playerId the player ID from Youtube.
   * @param {function} onReady a callback function to be called whenever the player is ready.
   */
  onIframeReady(domId, playerId, onReady) {
    this.player = new YT.Player(domId, {
      height: "360",
      width: "420",
      videoId: playerId,
      events: {
        onReady: ((event) => onReady(event)),
        onStateChange: ((event) => this.onPlayerStateChange(event))
      }
    });
  }

  /**
   * Get current time in seconds.
   *
   * @return {number} the current time in seconds.
   */
  getCurrentTime() {
    return Math.floor(this.player.getCurrentTime() * 1000);
  }

  /**
   * Move the player timeline.
   *
   * @param {number} milisec time where the player timeline should be moved.
   */
  seekTo(millsec) {
    return this.player.seekTo(millsec / 1000);
  }
}

export default Player;
