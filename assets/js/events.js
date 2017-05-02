import {
  warning,
  success
} from './notifications';

const initEvents = () => {

  const $document = $(document);

  // add CSRF token to all AJAX requests

  const csrfToken = $("meta[name='csrf-token']").attr("content");

  $document.ajaxSend((_, xhr) => {
    xhr.setRequestHeader('X-CSRF-Token', csrfToken);
  });

  // Remove any notifications

  window.setTimeout(() => {
    $('#notifications .callout').remove();
  }, 3000);

  // Highlight search text on click

  $("input[type='search']").on('click', event => $(event.currentTarget).select());

  // Alternate search url

  $("[data-search-url]").on('click', event => {
    const $this = $(event.currentTarget);
    const url = $this.attr('data-search-url');
    $this
      .parent('form')
      .attr('action', url)
      .submit();
  });

  // Subscriptions

  $document.on('click', '[data-unsubscribe]', event => {
    const $this = $(event.currentTarget);
    const url = $this.attr('data-unsubscribe-url');
    $.ajax(url, {
      method: 'DELETE',
      dataType: 'json',
    });

    $(`[data-unsubscribe-url="${url}"]`)
      .removeAttr('data-unsubscribe')
      .attr('data-subscribe', true)
      .attr('title', 'Subscribe to this podcast')
      .removeClass('secondary')
      .html('<i class="fa fa-podcast"></i>');
    warning('You have stopped following this podcast');
  });

  $document.on('click', '[data-subscribe]', event => {
    const $this = $(event.currentTarget);
    const url = $this.attr('data-subscribe-url');
    $.ajax(url, {
      method: 'POST',
      dataType: 'json',
    });
    $(`[data-subscribe-url="${url}"]`)
      .removeAttr('data-subscribe')
      .attr('data-unsubscribe', true)
      .attr('title', 'Unsubscribe from this podcast')
      .addClass('secondary')
      .html('<i class="fa fa-podcast"></i>');
    success('You are now following this podcast');
  });

  // Bookmarks

  $document.on('click', '[data-remove-bookmark]', event => {
    const $this = $(event.currentTarget);
    const url = $this.attr('data-remove-bookmark-url');
    $.ajax(url, {
      method: 'DELETE',
      dataType: 'json',
    });
    $this
      .removeAttr('data-remove-bookmark')
      .attr('data-add-bookmark', true)
      .attr('title', 'Bookmark this episode')
      .removeClass('secondary')
      .html('<i class="fa fa-bookmark-o"></i>');
    warning('Bookmark removed');
  });

  $document.on('click', '[data-add-bookmark]', event => {
    const $this = $(event.currentTarget);
    const url = $this.attr('data-add-bookmark-url');
    $.ajax(url, {
      method: 'POST',
      dataType: 'json',
    });
    $this
      .removeAttr('data-add-bookmark')
      .attr('data-remove-bookmark', true)
      .attr('title', 'Remove this bookmark')
      .addClass('secondary')
      .html('<i class="fa fa-bookmark"></i>');
    success('Bookmark added');
  });
}

export default initEvents;
