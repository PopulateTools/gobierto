/* eslint-disable no-undef */
import Table from './../../app/javascript/lib/vue-components/modules/Table.vue';
import TableColumnsSelector from './../../app/javascript/lib/vue-components/modules/TableColumnsSelector.vue';
import { render, screen, fireEvent } from '@testing-library/vue';

describe('table vue-component', () => {
  test('should render component', () => {
    render(Table)

    expect(screen.queryByTestId('table-component')).toBeTruthy()

  });

  test('should show a modal', async () => {
    render(TableColumnsSelector)
    const button = screen.getByTestId('table-button-modal')

    await fireEvent.click(button)

    expect(screen.queryByTestId('table-modal')).toBeTruthy()
  })

});
