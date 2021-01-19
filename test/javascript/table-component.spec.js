/* eslint-disable no-undef */
import Table from './../../app/javascript/lib/vue-components/modules/Table.vue';
import { render, screen, fireEvent } from '@testing-library/vue';

describe('table vue-component', () => {
  test('should render component', () => {
    const { container } = render(Table)

    expect(container.firstChild.firstChild.tagName).toBe('TABLE')

  });

  test('should show a modal', async () => {
    render(Table)
    const button = screen.getByText('showModal')

    await fireEvent.click(button)

    expect(screen.queryByText('Modal and checkboxes')).toBeTruthy()
  })

});
