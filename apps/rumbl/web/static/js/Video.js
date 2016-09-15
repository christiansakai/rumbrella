import Player from "./Player";

/**
 * Class representing the whole Video
 * object complete with chat box 
 * and annotations.
 */
class Video {

  /**
   * Create the video object in the DOM.
   *
   * @param {Phoenix.Socket} socket an instance of Phoenix.Socket
   * @param {DOM element} dom element where the actual player is instantiated.
   */
  constructor(socket, element) {
    if (!element) return;

    let playerId = element.getAttribute("data-player-id");
    let videoId = element.getAttribute("data-id");

    socket.connect();

    this.player = new Player(element.id, playerId, () => {
      this.onReady(videoId, socket);
    });
  }

  /**
   * Callback to be called after the
   * whole Video object instantiated.
   *
   * @param {string} videoId the dom ID where this whole video object is instantiated.
   * @param {Phoenix.Socket} socket an instance of Phoenix.Socket
   *
   */
  onReady(videoId, socket) {
    let msgContainer = document.getElementById("msg-container");
    let msgInput = document.getElementById("msg-input");
    let postButton = document.getElementById("msg-submit");
    let vidChannel = socket.channel(`videos:${videoId}`);

    // Whenever a timeline in the message container
    // gets clicked, move the Player to that timeline.
    msgContainer.addEventListener("click", e => {
      e.preventDefault();
      let seconds = e.target.getAttribute("data-seek") ||
                    e.target.parentNode.getAttribute("data-seek");

      if (!seconds) { return; }
      this.player.seekTo(seconds);
    });

    // Add a new annotation to the video
    // by pushing the annotation through socket
    // to be broadcasted across viewers.
    postButton.addEventListener("click", e => {
      const payload = {
        body: msgInput.value,
        at: this.player.getCurrentTime()
      };

      vidChannel
        .push("new_annotation", payload)
        .receive("error", e => console.log(e));

      msgInput.value = "";
    });

    // Whenever there is a new annotation coming,
    // update the last_seen_id, then render
    // the annotation. The last_seen_id is useful
    // for synchronizing state after a socket disconnect.
    vidChannel.on("new_annotation", (resp) => {
      vidChannel.params.last_seen_id = resp.id;
      this.renderAnnotation(msgContainer, resp);
    });

    // Upon joining the channel, render all
    // annotations starting from the last_seen_id
    vidChannel.join()
      .receive("ok", ({ annotations }) => {
        let ids = annotations.map(ann => ann.id);

        if (ids.length > 0) {
          vidChannel.params.last_seen_id = Math.max(...ids);
        }

        this.scheduleMessages(msgContainer, annotations);
      })
      .receive("error", reason => console.log("join failed", reason));

  }

  /**
   * Safely escape html?
   *
   * @param {string} str value to be inserted into HTML element.
   * 
   * @return {string} string to be safely inserted to HTML.
   */
  esc(str) {
    let div = document.createElement("div");
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  }

  /**
   * Render annotations inside message container.
   *
   * @param {DOM element} msgContainer dom element where annotations will be rendered.
   * @param {object} messageData data about message 
   * @param {object} messageData.user data about the user posting the message
   * @param {string} messageData.user.username the username of a user
   * @param {string} body the message body
   * @param {string} at timeline where this message is posted.
   */
  renderAnnotation(msgContainer, { user, body, at }) {
    let template = document.createElement("div");
    template.innerHTML = `
    <a href="#" data-seek="${this.esc(at)}">
      [${this.formatTime(at)}]
      <b>${this.esc(user.username)}</b>: ${this.esc(body)}
    </a>
    `;

    msgContainer.appendChild(template);
    msgContainer.scrollTop = msgContainer.scrollHeight;
  }

  /**
   * Schedule the rendering of annotations 
   * every one second.
   *
   * @param {DOM element} msgContainer dom element where annotations will be rendered.
   * @param {array} annotations array containing annotations.
   *
   */
  scheduleMessages(msgContainer, annotations) {
    setTimeout(() => {
      let ctime = this.player.getCurrentTime();
      let remaining = this.renderAtTime(annotations, ctime, msgContainer);
      this.scheduleMessages(msgContainer, remaining);
    }, 1000);
  }

  /**
   * Render annotations at a given time.
   *
   * @param {array} annotations array containing annotations.
   * @param {number} seconds the elapsed seconds of video time.
   * @param {DOM element} msgContainer dom element where annotations will be rendered.
   */
  renderAtTime(annotations, seconds, msgContainer) {
    return annotations.filter(ann => {
      if (ann.at > seconds) {
        return true;
      } else {
        this.renderAnnotation(msgContainer, ann);
        return false;
      }
    });
  }

  /**
   * Format an ISO time into readable format.
   *
   * @param {number} at the ISO time in milisecond.
   *
   * @return {string} formatted time.
   */
  formatTime(at) {
    let date = new Date(null);
    date.setSeconds(at / 1000);
    return date.toISOString().substr(14, 5);
  }
}

export default Video;
