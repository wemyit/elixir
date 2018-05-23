const Player = {
  player: null,

  init(domId, playerId, onReady){
    window.onYouTubeIframeAPIReady = () => {
      this.onIframeReady(domId, playerId, onReady);
    }
    const youTubeScriptTag = document.createElement('script');
    youTubeScriptTag.src = '//www.youtube.com/iframe_api';
    document.head.appendChild(youTubeScriptTag);
  },

  onIframeReady(domId, playerId, onReady) {
    this.player = new YT.Player(domId, {
      height: '360',
      width: '420',
      videoId: playerId,
      events: {
        'onReady': (event => onReady(event)),
        'onStateChange': (event => this.onPlayerStateChange(event)),
      }
    })
  },

  onPlayerStateChange(event) {},

  getCurrentTime() {
    return Math.floor(this.player.getCurrentTime() * 1000);
  },

  seekTo(millisec) {
    return this.player.seekTo(millisec / 1000);
  }
}

export default Player;