import {
  info,
  success
} from './notifications';

const initEvents = () => {

  const $document = $(document);

  // add CSRF token to all AJAX requests

  const csrfToken = $("meta[name='csrf-token']").attr("content");

  $document.ajaxSend((_, xhr) => {
    xhr.setRequestHeader('X-CSRF-Token', csrfToken);
  });

  // Highlight search text on click

  $("input[type='search']").on('click', event => $(event.currentTarget).select());

  // Subscriptions

  $document.on('click', '[data-unsubscribe]', event => {
    const $this = $(event.currentTarget);
    const url = $this.attr('data-unsubscribe-url');
    $.ajax(url, {
      method: 'DELETE'
    });
    $this
      .removeAttr('data-unsubscribe')
      .attr('data-subscribe', true)
      .attr('title', 'Subscribe to this podcast');
    $this
      .find('i.fa.fa-minus')
      .removeClass('fa-minus')
      .addClass('fa-plus');
    info('You have stopped following this podcast');
  });

  $document.on('click', '[data-subscribe]', event => {
    const $this = $(event.currentTarget);
    const url = $this.attr('data-subscribe-url');
    $.ajax(url, {
      method: 'POST'
    });
    $this
      .removeAttr('data-subscribe')
      .attr('data-unsubscribe', true)
      .attr('title', 'Unsubscribe from this podcast');
    $this
      .find('i.fa.fa-plus')
      .removeClass('fa-plus')
      .addClass('fa-minus');
    success('You are now following this podcast');
  });

  // Bookmarks

  $document.on('click', '[data-remove-bookmark]', event => {
    const $this = $(event.currentTarget);
    const url = $this.attr('data-remove-bookmark-url');
    $.ajax(url, {
      method: 'DELETE'
    });
    $this
      .removeAttr('data-remove-bookmark')
      .attr('data-add-bookmark', true)
      .attr('title', 'Bookmark this episode');
    $this
      .find('i.fa.fa-bookmark')
      .removeClass('fa-bookmark')
      .addClass('fa-bookmark-o');
    info('Bookmark removed');
  });

  $document.on('click', '[data-add-bookmark]', event => {
    const $this = $(event.currentTarget);
    const url = $this.attr('data-add-bookmark-url');
    $.ajax(url, {
      method: 'POST'
    });
    $this
      .removeAttr('data-add-bookmark')
      .attr('data-remove-bookmark', true)
      .attr('title', 'Remove this bookmark');
    $this
      .find('i.fa.fa-bookmark-o')
      .removeClass('fa-bookmark-o')
      .addClass('fa-bookmark');
    success('Bookmark added');
  });
}

export default initEvents;
